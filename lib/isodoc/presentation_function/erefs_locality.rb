module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def eref_localities(refs, target, node)
      if can_conflate_eref_rendering?(refs)
        l10n(", #{esc(eref_localities_conflated(refs, target, node))}"
          .gsub(/\s+/, " "), @lang, @script, { prev: target })
      else
        ret = resolve_eref_connectives(eref_locality_stacks(refs, target, node))
        l10n(ret.join.gsub(/\s+/, " "), @lang, @script, { prev: target })
      end
    end

    def eref_localities_conflated(refs, target, node)
      droploc = node["droploc"]
      node["droploc"] = true
      ret = resolve_eref_connectives(eref_locality_stacks(refs, target, node))
      node.delete("droploc") unless droploc
      eref_localities1({ target:, number: "pl",
                         type: refs.first.at(ns("./locality/@type")).text,
                         from: l10n(ret[1..].join), node:, lang: @lang })
    end

    def can_conflate_eref_rendering?(refs)
      (refs.size > 1 &&
        refs.all? { |r| r.name == "localityStack" } &&
        refs.all? { |r| r.xpath(ns("./locality")).size == 1 }) or return false
      first = refs.first.at(ns("./locality/@type")).text
      refs.all? { |r| r.at(ns("./locality/@type")).text == first }
    end

    def eref_locality_stacks(refs, target, node)
      ret = refs.each_with_index.with_object([]) do |(r, i), m|
        added = eref_locality_stack(r, i, target, node)
        added.empty? and next
        added.each { |a| m << a }
        i == refs.size - 1 and next
        m << eref_locality_delimiter(r)
      end
      ret.empty? ? ret : [{ conn: ", " }] + ret
    end

    def eref_locality_delimiter(ref)
      if ref&.next_element&.name == "localityStack"
        { conn: ref.next_element["connective"],
          custom: ref.next_element["custom-connective"] }
      else locality_delimiter(ref)
      end
    end

    def eref_locality_stack(ref, idx, target, node)
      ret = []
      if ref.name == "localityStack"
        ret = eref_locality_stack1(ref, target, node, ret)
      else
        l = eref_localities0(ref, idx, target, node) and ret << { ref: l }
      end
      ret[-1] && ret[-1][:conn] == ", " and ret.pop
      ret
    end

    def eref_locality_stack1(ref, target, node, ret)
      if ref["connective"] == "from" && ref["custom-connective"]
        # TODO deal better with languages with mandatory from connective
        ret << { conn: "from", custom: ref["custom-connective"] }
      end
      ref.elements.each_with_index do |rr, j|
        l = eref_localities0(rr, j, target, node) or next
        ret << { ref: l }
        ret << locality_delimiter(rr) unless j == ref.elements.size - 1
      end
      ret
    end

    def locality_delimiter(_loc)
      { conn: ", " }
    end

    def eref_localities0(ref, _idx, target, node)
      if ref["type"] == "whole" then @i18n.wholeoftext
      else
        eref_localities1({ target:, type: ref["type"], number: "sg",
                           from: ref.at(ns("./referenceFrom"))&.text,
                           upto: ref.at(ns("./referenceTo"))&.text, node:,
                           lang: @lang })
      end
    end

    # Suspended, this is an ordinal that GB asked for, not applicable
    # for non-integers, and not desired for JIS
    def eref_localities1_zh(opt)
      ret = "第#{esc opt[:from]}" if opt[:from]
      ret += "&#x2013;#{esc opt[:upto]}" if opt[:upto]
      loc = eref_locality_populate(opt[:type], opt[:node], "sg")
      ret += " #{loc}" unless opt[:node]["droploc"] == "true"
      ret
    end

    def eref_localities1(opt)
      opt[:type] == "anchor" and return nil
      # %(zh ja ko).include?(opt[:lang]) and
      # return l10n(eref_localities1_zh(opt))
      ret = eref_locality_populate(opt[:type], opt[:node], opt[:number])
      ret += " <esc>#{opt[:from]}</esc>" if opt[:from]
      ret += "&#x2013;<esc>#{opt[:upto]}</esc>" if opt[:upto]
      l10n(ret)
    end

    def eref_locality_populate(type, node, number)
      node["droploc"] == "true" and return ""
      loc = type.sub(/^locality:/, "")
      ret = @i18n.locality[loc] || loc
      number == "pl" and ret = @i18n.inflect(ret, number: "pl")
      ret = case node["case"]
            when "lowercase" then ret.downcase
            else Metanorma::Utils.strict_capitalize_first(ret)
            end
      " #{ret}"
    end
  end
end
