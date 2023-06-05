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
      return unless xref_empty?(node)

      link = anchor_linkend(node, docid_l10n(node["target"] ||
                                             expand_citeas(node["citeas"])))
      link += eref_localities(node.xpath(ns("./locality | ./localityStack")),
                              link, node)
      non_locality_elems(node).each(&:remove)
      node.add_child(cleanup_entities(link))
      unnest_linkend(node)
    end
    # so not <origin bibitemid="ISO7301" citeas="ISO 7301">
    # <locality type="section"><reference>3.1</reference></locality></origin>

    def unnest_linkend(node)
      return unless node.at(ns("./xref[@nested]"))

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
