require "metanorma-utils"

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
        expand_citeas(docid_l10n(node["citeas"]))
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
      node.at(ns("./xref[@nested]")) or return
      node.xpath(ns("./xref[@nested]")).each { |x| x.delete("nested") }
      node.xpath(ns("./location | ./locationStack")).each(&:remove)
      node.replace(node.children)
    end

    def xref_empty?(node)
      c1 = non_locality_elems(node).select { |c| !c.text? || /\S/.match(c) }
      c1.empty?
    end

    def anchor_id_postprocess(node); end

    def xref(docxml)
      docxml.xpath(ns("//xref")).each { |f| xref1(f) }
      docxml.xpath(ns("//xref//xref")).each { |f| f.replace(f.children) }
    end

    def eref(docxml)
      docxml.xpath(ns("//eref")).each { |f| xref1(f) }
      docxml.xpath(ns("//eref//xref")).each { |f| f.replace(f.children) }
      docxml.xpath(ns("//erefstack")).each { |f| erefstack1(f) }
    end

    def origin(docxml)
      docxml.xpath(ns("//origin[not(termref)]")).each { |f| xref1(f) }
    end

    def quotesource(docxml)
      docxml.xpath(ns("//quote/source")).each { |f| xref1(f) }
      docxml.xpath(ns("//quote/source//xref")).each do |f|
        f.replace(f.children)
      end
    end

    def xref1(node)
      get_linkend(node)
    end

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
        n.name = "tt"
      end
    end

    def date(docxml)
      (docxml.xpath(ns("//date")) -
       docxml.xpath(ns("//bibdata/date | //bibitem//date"))).each do |d|
         date1(d)
       end
    end

    def date1(elem)
      elem.replace(@i18n.date(elem["value"], elem["format"].strip))
    end

    def inline_format(docxml)
      custom_charset(docxml)
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
      (f - formats).size == f.size or elem["formats"] = "all"
      elem["formats"] == "all" and elem["formats"] = formats.join(",")
      elem["formats"] = ",#{elem['formats']},"
    end

    private

    def extract_custom_charsets(docxml)
      docxml.xpath(ns("//presentation-metadata/custom-charset-font")).
        each_with_object({}) do |x, m|
          kv = x.text.split(":", 2)
          m[kv[0]] = kv[1]
        end
    end

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
