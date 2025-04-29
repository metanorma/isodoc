require "metanorma-utils"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def citeas(xmldoc)
      xmldoc.xpath(ns("//fmt-eref | //fmt-origin | //fmt-link"))
        .each do |e|
        sem_xml_descendant?(e) and next
        e["bibitemid"] && e["citeas"] or next
        a = @xrefs.anchor(e["bibitemid"], :xref, false) or next
        e["citeas"] = citeas_cleanup(a)
        # link generated in collection postprocessing from eref
        e.name == "fmt-link" && e.text.empty? and e.children = e["citeas"]
      end
    end

    def citeas_cleanup(ref)
      if ref.include?("<")
        xml = Nokogiri::XML("<root>#{ref}</root>")
        xml.xpath("//semx").each { |x| x.replace(x.children) }
        ref = to_xml(xml.at("//root").children)
      end
      ref
    end

    def expand_citeas(text)
      text.nil? and return text
      HTMLEntities.new.decode(text.gsub("&amp;#x", "&#"))
    end

    def erefstack1(elem)
      locs = elem.xpath(ns("./semx/fmt-eref")).map do |e|
        [e["connective"], to_xml(e.parent.remove)]
      end.flatten
      ret = resolve_eref_connectives(locs)
      elem.next = "<semx element='erefstack' source='#{elem['id']}'>#{ret[1]}</semx>"
    end

    def eref_localities(refs, target, node)
      if can_conflate_eref_rendering?(refs)
        l10n(", #{eref_localities_conflated(refs, target, node)}"
          .gsub(/\s+/, " "))
      else
        ret = resolve_eref_connectives(eref_locality_stacks(refs, target, node))
        l10n(ret.join.gsub(/\s+/, " "))
      end
    end

    def eref_localities_conflated(refs, target, node)
      droploc = node["droploc"]
      node["droploc"] = true
      ret = resolve_eref_connectives(eref_locality_stacks(refs, target,
                                                          node))
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

    def resolve_eref_connectives(locs)
      locs = resolve_comma_connectives(locs)
      locs = resolve_to_connectives(locs)
      locs.size < 3 and return locs
      locs = locs.each_slice(2).with_object([]) do |a, m|
        m << { conn: a[0], label: a[1] }
      end
      [", ", combine_conn(locs)]
    end

    def resolve_comma_connectives(locs)
      locs1 = []
      add = ""
      until locs.empty?
        locs, locs1, add = resolve_comma_connectives1(locs, locs1, add)
      end
      locs1 << add unless add.empty?
      locs1
    end

    def resolve_comma_connectives1(locs, locs1, add)
      if [", ", " ", ""].include?(locs[1])
        add += locs[0..2].join
        locs.shift(3)
      else
        locs1 << add unless add.empty?
        add = ""
        locs1 << locs.shift
      end
      [locs, locs1, add]
    end

    def resolve_to_connectives(locs)
      locs1 = []
      until locs.empty?
        if locs[1] == "to"
          locs1 << connectives_spans(@i18n.chain_to.sub("%1", locs[0])
            .sub("%2", locs[2]))
          locs.shift(3)
        else locs1 << locs.shift
        end
      end
      locs1
    end

    def eref_locality_stacks(refs, target, node)
      ret = refs.each_with_index.with_object([]) do |(r, i), m|
        added = eref_locality_stack(r, i, target, node)
        added.empty? and next
        added.each { |a| m << a }
        i == refs.size - 1 and next
        m << eref_locality_delimiter(r)
      end
      ret.empty? ? ret : [", "] + ret
    end

    def eref_locality_delimiter(ref)
      if ref&.next_element&.name == "localityStack"
        ref.next_element["connective"]
      else locality_delimiter(ref)
      end
    end

    def eref_locality_stack(ref, idx, target, node)
      ret = []
      if ref.name == "localityStack"
        ret = eref_locality_stack1(ref, target, node, ret)
      else
        l = eref_localities0(ref, idx, target, node) and ret << l
      end
      ret[-1] == ", " and ret.pop
      ret
    end

    def eref_locality_stack1(ref, target, node, ret)
      ref.elements.each_with_index do |rr, j|
        l = eref_localities0(rr, j, target, node) or next
        ret << l
        ret << locality_delimiter(rr) unless j == ref.elements.size - 1
      end
      ret
    end

    def locality_delimiter(_loc)
      ", "
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

    def eref_localities1_zh(opt)
      ret = "第#{opt[:from]}" if opt[:from]
      ret += "&#x2013;#{opt[:upto]}" if opt[:upto]
      loc = eref_locality_populate(opt[:type], opt[:node], "sg")
      ret += " #{loc}" unless opt[:node]["droploc"] == "true"
      ret
    end

    def eref_localities1(opt)
      opt[:type] == "anchor" and return nil
      opt[:lang] == "zh" and
        return l10n(eref_localities1_zh(opt))
      ret = eref_locality_populate(opt[:type], opt[:node], opt[:number])
      ret += " #{opt[:from]}" if opt[:from]
      ret += "&#x2013;#{opt[:upto]}" if opt[:upto]
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

    def eref2link(docxml)
      docxml.xpath(ns("//display-text")).each { |f| f.replace(f.children) }
      docxml.xpath(ns("//fmt-eref | //fmt-origin[not(.//termref)]"))
        .each do |e|
        sem_xml_descendant?(e) and next
        href = eref_target(e) or next
        e.xpath(ns("./locality | ./localityStack")).each(&:remove)
        if href[:type] == :anchor then eref2xref(e)
        else eref2link1(e, href)
        end
      end
    end

    def eref2xref(node)
      node.name = "fmt-xref"
      node["target"] = node["bibitemid"]
      node.delete("bibitemid")
      node.delete("citeas")
      node["type"] == "footnote" and node.wrap("<sup></sup>")
    end

    def eref2link1(node, href)
      url = href[:link]
      att = href[:type] == :attachment ? "attachment='true'" : ""
      repl = "<fmt-link #{att} target='#{url}'>#{node.children}</link>"
      node["type"] == "footnote" and repl = "<sup>#{repl}</sup>"
      node.replace(repl)
    end

    def suffix_url(url)
      url.nil? || %r{^https?://|^#}.match?(url) and return url
      File.extname(url).empty? or return url
      url.sub(/#{File.extname(url)}$/, ".html")
    end

    def eref_target(node)
      u = eref_url(node["bibitemid"]) or return nil
      url = suffix_url(u[:link])
      anchor = node.at(ns(".//locality[@type = 'anchor']"))
      /^#/.match?(url) || !anchor and return { link: url, type: u[:type] }
      { link: "#{url}##{anchor.text.strip}", type: u[:type] }
    end

    def eref_url_prep(id)
      @bibitem_lookup.nil? and return nil
      @bibitem_lookup[id]
    end

    def eref_url(id)
      b = eref_url_prep(id) or return nil
      %i(attachment citation).each do |x|
        u = b.at(ns("./uri[@type = '#{x}'][@language = '#{@lang}']")) ||
          b.at(ns("./uri[@type = '#{x}']")) and return { link: u.text, type: x }
      end
      if b["hidden"] == "true"
        u = b.at(ns("./uri")) or return nil
        { link: u.text, type: :citation }
      else { link: "##{id}", type: :anchor }
      end
    end
  end
end
