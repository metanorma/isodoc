module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def dl(docxml)
      docxml.xpath(ns("//dl")).each { |f| dl1(f) }
    end

    def dl1(elem)
      elem.at(ns("./name")) and
        prefix_name(elem, {}, "", "name") # copy name to fmt-name
    end

    def ul(docxml)
      docxml.xpath(ns("//ul")).each { |f| ul1(f) }
      docxml.xpath(ns("//ul/li")).each { |f| ul_label(f) }
    end

    def ul1(elem)
      elem.at(ns("./name")) and
        prefix_name(elem, {}, "", "name") # copy name to fmt-name
    end

    def ol(docxml)
      docxml.xpath(ns("//ol")).each { |f| ol1(f) }
      @xrefs.list_anchor_names(docxml.xpath(ns(@xrefs.sections_xpath)))
      docxml.xpath(ns("//ol/li")).each { |f| ol_label(f) }
    end

    def ol_depth(node)
      depth = node.ancestors("ul, ol").size + 1
      @counter.ol_type(node, depth) # defined in Xref::Counter
    end

    def ol1(elem)
      elem["type"] ||= ol_depth(elem).to_s # feeds ol_label_format
      elem.at(ns("./name")) and
        prefix_name(elem, {}, "", "name") # copy name to fmt-name
    end

    def ol_label(elem)
      val = @xrefs.anchor(elem["id"], :label, false)
      semx = "<semx element='autonum' source='#{elem['id']}'>#{val}</semx>"
      lbl = "<fmt-name>#{ol_label_format(semx, elem)}</fmt-name>"
      elem.add_first_child(lbl)
    end

    def ol_label_template(_elem)
      {
        alphabet: %{%<span class="fmt-label-delim">)</span>},
        alphabet_upper: %{%<span class="fmt-label-delim">.</span>},
        roman: %{%<span class="fmt-label-delim">)</span>},
        roman_upper: %{%<span class="fmt-label-delim">.</span>},
        arabic: %{%<span class="fmt-label-delim">)</span>},
      }
    end

    def ol_label_format(semx, elem)
      template = ol_label_template(elem)[elem.parent["type"].to_sym]
      template.sub("%", semx)
    end

    def ul_label_list(_elem)
      %w(&#x2014;)
    end

    def ul_label_list_from_metadata(docxml)
      list = docxml.xpath(ns("//presentation-metadata/ul-label-list"))
      list.empty? and return nil
      list.map(&:text)
    end

    def ul_label(elem)
      val = ul_label_value(elem)
      semx = "<semx element='autonum' source='#{elem['id']}'>#{val}</semx>"
      lbl = "<fmt-name>#{semx}</fmt-name>"
      elem.add_first_child(lbl)
    end

    def ul_label_value(elem)
      depth = elem.ancestors("ul, ol").size
      val = ul_label_list_from_metadata(elem.document.root) ||
        ul_label_list(elem)
      val[(depth - 1) % val.size]
    end
  end
end
