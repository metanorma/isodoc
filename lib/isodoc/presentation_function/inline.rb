require "metanorma-utils"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def prefix_container(container, linkend, _target)
      l10n("#{@xrefs.anchor(container, :xref)}, #{linkend}")
    end

    def anchor_linkend(node, linkend)
      if node["citeas"].nil? && node["bibitemid"]
        return @xrefs.anchor(node["bibitemid"], :xref) || "???"
      elsif node["target"] && node["droploc"]
        return @xrefs.anchor(node["target"], :value) ||
            @xrefs.anchor(node["target"], :label) ||
            @xrefs.anchor(node["target"], :xref) || "???"
      elsif node["target"] && !/.#./.match(node["target"])
        linkend = anchor_linkend1(node)
      end

      linkend || "???"
    end

    def anchor_linkend1(node)
      linkend = @xrefs.anchor(node["target"], :xref)
      container = @xrefs.anchor(node["target"], :container, false)
      (container && get_note_container_id(node) != container &&
       @xrefs.get[node["target"]]) and
        linkend = prefix_container(container, linkend, node["target"])
      capitalise_xref(node, linkend)
    end

    def capitalise_xref(node, linkend)
      return linkend unless %w(Latn Cyrl Grek).include? @script
      return linkend&.capitalize if node["case"] == "capital"
      return linkend&.downcase if node["case"] == "lowercase"
      return linkend if linkend[0, 1].match?(/\p{Upper}/)

      capitalise_xref1(node, linkend)
    end

    def capitalise_xref1(node, linkend)
      prec = nearest_block_parent(node).xpath("./descendant-or-self::text()") &
        node.xpath("./preceding::text()")
      if prec.empty? || /(?!<[^.].)\.\s+$/.match(prec.map(&:text).join)
        linkend&.capitalize
      else linkend
      end
    end

    def nearest_block_parent(node)
      until %w(p title td th name formula li dt dd sourcecode pre)
          .include?(node.name)
        node = node.parent
      end
      node
    end

    def non_locality_elems(node)
      node.children.reject do |c|
        %w{locality localityStack}.include? c.name
      end
    end

    def get_linkend(node)
      c1 = non_locality_elems(node).select { |c| !c.text? || /\S/.match(c) }
      return unless c1.empty?

      link = anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))
      link += eref_localities(node.xpath(ns("./locality | ./localityStack")),
                              link, node)
      non_locality_elems(node).each(&:remove)
      node.add_child(link)
    end
    # so not <origin bibitemid="ISO7301" citeas="ISO 7301">
    # <locality type="section"><reference>3.1</reference></locality></origin>

    def eref_localities(refs, target, node)
      ret = ""
      refs.each_with_index do |r, i|
        delim = ","
        delim = ";" if r.name == "localityStack" && i.positive?
        ret = eref_locality_stack(r, i, target, delim, ret, node)
      end
      ret
    end

    def eref_locality_stack(ref, idx, target, delim, ret, node)
      if ref.name == "localityStack"
        ref.elements.each_with_index do |rr, j|
          ret += eref_localities0(rr, j, target, delim, node)
          delim = ","
        end
      else
        ret += eref_localities0(ref, idx, target, delim, node)
      end
      ret
    end

    def eref_localities0(ref, _idx, target, delim, node)
      if ref["type"] == "whole" then l10n("#{delim} #{@i18n.wholeoftext}")
      else
        eref_localities1(target, ref["type"], ref.at(ns("./referenceFrom")),
                         ref.at(ns("./referenceTo")), delim, node, @lang)
      end
    end

    # TODO: move to localization file
    def eref_localities1_zh(_target, type, from, upto, node, delim)
      ret = "#{delim} 第#{from.text}" if from
      ret += "&ndash;#{upto.text}" if upto
      loc = (@i18n.locality[type] || type.sub(/^locality:/, "").capitalize)
      ret += " #{loc}" unless node["droploc"] == "true"
      ret
    end

    # TODO: move to localization file
    def eref_localities1(target, type, from, upto, delim, node, lang = "en")
      return "" if type == "anchor"

      lang == "zh" and
        return l10n(eref_localities1_zh(target, type, from, upto, node, delim))
      ret = delim
      ret += eref_locality_populate(type, node)
      ret += " #{from.text}" if from
      ret += "&ndash;#{upto.text}" if upto
      l10n(ret)
    end

    def eref_locality_populate(type, node)
      return "" if node["droploc"] == "true"

      loc = @i18n.locality[type] || type.sub(/^locality:/, "")
      loc = case node["case"]
            when "lowercase" then loc.downcase
            else Metanorma::Utils.strict_capitalize_first(loc)
            end
      " #{loc}"
    end

    def xref(docxml)
      docxml.xpath(ns("//xref")).each { |f| xref1(f) }
    end

    def eref(docxml)
      docxml.xpath(ns("//eref")).each { |f| xref1(f) }
    end

    def origin(docxml)
      docxml.xpath(ns("//origin[not(termref)]")).each { |f| xref1(f) }
    end

    def quotesource(docxml)
      docxml.xpath(ns("//quote/source")).each { |f| xref1(f) }
    end

    def xref1(node)
      get_linkend(node)
    end

    def concept(docxml)
      docxml.xpath(ns("//concept")).each { |f| concept1(f) }
    end

    def concept1(node)
      xref = node&.at(ns("./xref/@target"))&.text or
        return concept_render(node, ital: node["ital"] || "true",
                                    ref: node["ref"] || "true",
                                    linkref: node["linkref"] || "true",
                                    linkmention: node["linkmention"] || "false")
      if node.at(ns("//definitions//dt[@id = '#{xref}']"))
        concept_render(node, ital: node["ital"] || "false",
                             ref: node["ref"] || "false",
                             linkref: node["linkref"] || "true",
                             linkmention: node["linkmention"] || "false")
      else concept_render(node, ital: node["ital"] || "true",
                                ref: node["ref"] || "true",
                                linkref: node["linkref"] || "true",
                                linkmention: node["linkmention"] || "false")
      end
    end

    def concept_render(node, opts)
      node&.at(ns("./refterm"))&.remove
      r = node.at(ns("./renderterm"))
      ref = node.at(ns("./xref | ./eref | ./termref"))
      ref && opts[:ref] != "false" and r&.next = " "
      opts[:ital] == "true" and r&.name = "em"
      if opts[:linkmention] == "true" && !r.nil? && !ref.nil?
        ref2 = ref.clone
        r2 = r.clone
        r.replace(ref2).children = r2
      end
      concept1_ref(node, ref, opts)
      if opts[:ital] == "false"
        r = node.at(ns("./renderterm"))
        r&.replace(r&.children)
      end
      node.replace(node.children)
    end

    def concept1_ref(_node, ref, opts)
      ref.nil? and return
      return ref.remove if opts[:ref] == "false"

      r = concept1_ref_content(ref)
      ref = r.at("./descendant-or-self::xmlns:xref | "\
                 "./descendant-or-self::xmlns:eref | "\
                 "./descendant-or-self::xmlns:termref")
      %w(xref eref).include? ref&.name and get_linkend(ref)
      if opts[:linkref] == "false" && %w(xref eref).include?(ref&.name)
        ref.replace(ref.children)
      end
    end

    def concept1_ref_content(ref)
      if non_locality_elems(ref).select do |c|
           !c.text? || /\S/.match(c)
         end.empty?
        ref.replace(@i18n.term_defined_in.sub(/%/,
                                              ref.to_xml))
      else ref.replace("[#{ref.to_xml}]")
      end
    end

    def variant(docxml)
      docxml.xpath(ns("//variant")).each { |f| variant1(f) }
      docxml.xpath(ns("//variant[@remove = 'true']")).each(&:remove)
      docxml.xpath(ns("//variant")).each do |v|
        next unless v&.next&.name == "variant"

        v.next = "/"
      end
      docxml.xpath(ns("//variant")).each { |f| f.replace(f.children) }
    end

    def variant1(node)
      if (!node["lang"] || node["lang"] == @lang) &&
          (!node["script"] || node["script"] == @script)
      elsif found_matching_variant_sibling(node)
        node["remove"] = "true"
      end
    end

    private

    def found_matching_variant_sibling(node)
      prev = node.xpath("./preceding-sibling::xmlns:variant")
      foll = node.xpath("./following-sibling::xmlns:variant")
      found = false
      (prev + foll).each do |n|
        found = true if n["lang"] == @lang &&
          (!n["script"] || n["script"] == @script)
      end
      found
    end
  end
end
