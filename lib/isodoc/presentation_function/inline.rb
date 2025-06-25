require "metanorma-utils"
require "csv"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def non_locality_elems(node)
      node.children.reject do |c|
        %w{locality localityStack location}.include? c.name
      end
    end

    def get_linkend(node)
      node["style"] == "id" and anchor_id_postprocess(node)
      xref_empty?(node) or return
      target = docid_l10n(node["target"]) ||
        docid_l10n(expand_citeas(node["citeas"]))
      link = anchor_linkend(node, target)
      link += eref_localities(node.xpath(ns("./locality | ./localityStack")),
                              link, node)
      non_locality_elems(node).each(&:remove)
      node.add_child(cleanup_entities(link))
      unnest_linkend(node)
    end
    # so not <origin bibitemid="ISO7301" citeas="ISO 7301">
    # <locality type="section"><reference>3.1</reference></locality></origin>

    def unnest_linkend(node)
      node.at(ns("./fmt-xref[@nested]")) or return
      node.xpath(ns("./fmt-xref[@nested]")).each { |x| x.delete("nested") }
      node.xpath(ns("./location | ./locationStack")).each(&:remove)
      node.replace(node.children)
    end

    def xref_empty?(node)
      c1 = non_locality_elems(node).select { |c| !c.text? || /\S/.match(c) }
      c1.empty?
    end

    def anchor_id_postprocess(node); end

    def xref(docxml)
      docxml.xpath(ns("//fmt-xref")).each { |f| xref1(f) }
      docxml.xpath(ns("//fmt-xref//fmt-xref")).each do |f|
        f.replace(f.children)
      end
      docxml.xpath(ns("//fmt-xref//xref")).each { |f| f.replace(f.children) }
    end

    def eref(docxml)
      docxml.xpath(ns("//eref[@deleteme]")).each { |f| redundant_eref(f) }
      docxml.xpath(ns("//fmt-eref")).each { |f| xref1(f) }
      docxml.xpath(ns("//fmt-eref//fmt-xref")).each do |f|
        f.replace(f.children)
      end
      docxml.xpath(ns("//erefstack")).each { |f| erefstack1(f) }
    end

    # redundant eref copied from quote/source
    def redundant_eref(elem)
      if elem.next.name == "semx"
        elem.next.elements.first.delete("deleteme")
        elem.next.replace(elem.next.children)
      end
      elem.remove
    end

    def origin(docxml)
      docxml.xpath(ns("//fmt-origin[not(.//termref)]")).each { |f| xref1(f) }
    end

    # do not change to Presentation XML rendering
    def sem_xml_descendant?(node)
      ancestor_names = node.ancestors.map(&:name)
      %w[preferred admitted deprecated related definition source]
        .any? do |name|
        ancestor_names.include?(name)
      end and return true
      %w[xref eref origin link name title].any? do |name|
        ancestor_names.include?(name)
      end and return true
      ancestor_names.include?("bibitem") &&
        %w[formattedref biblio-tag].none? do |name|
          ancestor_names.include?(name)
        end and return true
      (ancestor_names & %w[requirement recommendation permission]).any? &&
        !ancestor_names.include?("fmt-provision") and return true

      false
    end

    def xref1(node)
      sem_xml_descendant?(node) and return
      get_linkend(node)
    end

    # there should be no //variant in bibdata now
    def variant(xml)
      b = xml.xpath(ns("//bibdata//variant"))
      (xml.xpath(ns("//variant")) - b).each { |f| variant1(f) }
      (xml.xpath(ns("//variant[@remove = 'true']")) - b).each(&:remove)
      (xml.xpath(ns("//variant")) - b).each do |v|
        v.next&.name == "variant" or next
        v.next = "/"
      end
      (xml.xpath(ns("//variant")) - b).each { |f| f.replace(f.children) }
    end

    def variant1(node)
      if !((!node["lang"] || node["lang"] == @lang) &&
          (!node["script"] || node["script"] == @script)) &&
          found_matching_variant_sibling(node)
        node["remove"] = "true"
      end
    end

    def identifier(docxml)
      docxml.xpath(ns("//identifier")).each do |n|
        %w(bibdata bibitem requirement recommendation permission)
          .include?(n.parent.name) and next
        s = semx_fmt_dup(n)
        n.next = "<fmt-identifier><tt>#{to_xml(s)}</tt></fmt-identifier>"
      end
    end

    def date(docxml)
      (docxml.xpath(ns("//date")) -
       docxml.xpath(ns("//bibdata/date | //bibitem//date"))).each do |d|
         date1(d)
       end
    end

    def date1(elem)
      elem["value"] && elem["format"] or return
      val = @i18n.date(elem["value"], elem["format"].strip)
      d = semx_fmt_dup(elem)
      d << val
      elem.next = "<fmt-date>#{to_xml(d)}</fmt-date>"
    end

    def inline_format(docxml)
      custom_charset(docxml)
      text_transform(docxml)
    end

    def text_transform(docxml)
      docxml.xpath(ns("//span[contains(@style, 'text-transform')]")).each do |s|
        text_transform1(s)
      end
    end

    def text_transform1(span)
      m = span["style"].split(/;\s*/)
      i = m.index { |x| /^text-transform/.match?(x) }
      value = m[i].sub(/^text-transform:/, "")
      change_case(span, value, true)
      m[i] = "text-transform:none"
      span["style"] = m.join(";")
    end

    def change_case(span, value, seen_space)
      span.traverse do |s|
        s.text? or next
        case value
        when "uppercase" then s.replace s.text.upcase
        when "lowercase" then s.replace s.text.downcase
        when "capitalize"
          s.replace conditional_capitalize(s.text, seen_space)
        end
        seen_space = /\s$/.match?(s.text)
      end
    end

    def conditional_capitalize(text, seen_space)
      m = text.split(/(?<=\s)/)
      ((seen_space ? 0 : 1)...m.size).each do |i|
        m[i] = m[i].capitalize
      end
      m.join
    end

    def custom_charset(docxml)
      charsets = extract_custom_charsets(docxml)
      docxml.xpath(ns("//span[@custom-charset]")).each do |s|
        s["style"] ||= ""
        s["style"] += ";font-family:#{charsets[s['custom-charset']]}"
      end
    end

    def passthrough(docxml)
      formats = @output_formats.keys
      docxml.xpath(ns("//passthrough")).each do |p|
        passthrough1(p, formats)
      end
    end

    def passthrough1(elem, formats)
      (elem["formats"] && !elem["formats"].empty?) or elem["formats"] = "all"
      f = elem["formats"].split(",")
      (f - formats).size == f.size or f = "all"
      f == ["all"] and f = formats.dup
      elem["formats"] = " #{f.join(' ')} "
    end

    def extract_custom_charsets(docxml)
      docxml.xpath(ns("//presentation-metadata/custom-charset-font"))
        .each_with_object({}) do |line, m|
        line.text.split(",").map(&:strip).each do |x|
          kv = x.split(":", 2)
          m[kv[0]] = kv[1]
        end
      end
    end

    def ruby(docxml)
      (docxml.xpath(ns("//ruby")) - docxml.xpath(ns("//ruby//ruby")))
        .each do |r|
        ruby1(r)
      end
    end

    def ruby1(elem)
      v = elem.at(ns("./ruby-pronunciation | ./ruby-annotation")).remove
      elem.xpath(ns("./ruby")).each do |r|
        ruby1(r)
      end
      t = elem.children.to_xml
      elem.replace("<ruby><rb>#{t}</rb><rt>#{v['value']}</rt></ruby>")
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
