module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    # TODO will go back to just one source/modification, preserving it
    def source(docxml)
      fmt_source(docxml)
      docxml.xpath(ns("//fmt-source/source/modification")).each do |f|
        source_modification(f)
      end
      source_types(docxml)
      docxml.xpath(ns("//fmt-source/source")).each do |f|
        f.replace(semx_fmt_dup(f))
      end
    end

    def source_types(docxml)
      docxml.xpath(ns("//table/fmt-source")).each { |f| tablesource(f) }
      docxml.xpath(ns("//figure/fmt-source")).each { |f| figuresource(f) }
    end

    def fmt_source(docxml)
      n = docxml.xpath(ns("//source")) - docxml.xpath(ns("//term//source")) -
        docxml.xpath(ns("//quote/source"))
      n.each do |s|
        dup = s.clone
        modification_dup_align(s, dup)
        s.next = "<fmt-source>#{to_xml(dup)}</fmt-source>"
      end
    end

    def tablesource(elem)
      source1(elem, :table)
    end

    def figuresource(elem)
      source1(elem, :figure)
    end

    def source_join_delim(_elem)
      "; "
    end

    def source1(elem, ancestor)
      esc_origin(elem)
      source_elems = source1_gather(elem)
      source_elems.each do |e|
        esc_origin(e)
        elem << "#{source_join_delim(elem)}#{to_xml(e.remove.children).strip}"
      end
      source1_label(elem, @i18n.l10n(to_xml(elem.children).strip), ancestor)
    end

    def source1_gather(elem)
      source_elems = []
      while elem = elem&.next_element
        case elem.name
        when "source"
        when "fmt-source"
          source_elems << elem
        else break
        end
      end
      source_elems
    end

    def source1_label(elem, sources, _ancestor)
      elem.children = l10n("[#{@i18n.source}: #{esc sources}]")
    end

    def source_modification(mod)
      termsource_modification(mod.parent)
    end
  end
end
