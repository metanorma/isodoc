module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def figure(docxml)
      docxml.xpath(ns("//figure")).each do |f|
        figure1(f)
      end
    end

    def figure1(f)
      return sourcecode1(f) if f["class"] == "pseudocode" ||
        f["type"] == "pseudocode"
      return if labelled_ancestor(f) && f.ancestors("figure").empty?
      return if f.at(ns("./figure")) and !f.at(ns("./name"))
      lbl = @xrefs.anchor(f['id'], :label, false) or return
      prefix_name(f, "&nbsp;&mdash; ", l10n("#{@figure_lbl} #{lbl}"), "name")
    end

    def prefix_name(f, delim, number, elem)
      return if number.nil? || number.empty?
      unless name = f.at(ns("./#{elem}"))
        f.children.empty? and f.add_child("<#{elem}></#{elem}>") or
          f.children.first.previous = "<#{elem}></#{elem}>"
          name = f.children.first
      end
      name.children.empty? ? name.add_child(number) :
        ( name.children.first.previous = "#{number}#{delim}" )
    end

    def sourcecode(docxml)
      docxml.xpath(ns("//sourcecode")).each do |f|
        sourcecode1(f)
      end
    end

    def sourcecode1(f)
      return if labelled_ancestor(f)
      return unless f.ancestors("example").empty?
      lbl = @xrefs.anchor(f['id'], :label, false) or return
      prefix_name(f, "&nbsp;&mdash; ", l10n("#{@figure_lbl} #{lbl}"), "name")
    end

    def formula(docxml)
      docxml.xpath(ns("//formula")).each do |f|
        formula1(f)
      end
    end

    # introduce name element
    def formula1(f)
      lbl = @xrefs.anchor(f['id'], :label, false)
      prefix_name(f, "", lbl, "name")
    end

    def example(docxml)
      docxml.xpath(ns("//example")).each do |f|
        example1(f)
      end
    end

    def termexample(docxml)
      docxml.xpath(ns("//termexample")).each do |f|
        example1(f)
      end
    end

    def example1(f)
      n = @xrefs.get[f["id"]]
      lbl = (n.nil? || n[:label].nil? || n[:label].empty?) ? @example_lbl :
        l10n("#{@example_lbl} #{n[:label]}")
      prefix_name(f, "&nbsp;&mdash; ", lbl, "name")
    end

    def note(docxml)
      docxml.xpath(ns("//note")).each do |f|
        note1(f)
      end
    end

    # introduce name element
    def note1(f)
      return if f.parent.name == "bibitem"
      n = @xrefs.get[f["id"]]
      lbl = (@note_lbl if n.nil? || n[:label].nil? || n[:label].empty?) ?
        @note_lbl : l10n("#{@note_lbl} #{n[:label]}")
      prefix_name(f, "", lbl, "name")
    end

    def termnote(docxml)
      docxml.xpath(ns("//termnote")).each do |f|
        termnote1(f)
      end
    end

    # introduce name element
    def termnote1(f)
      lbl = l10n(@xrefs.anchor(f['id'], :label) || '???')
      prefix_name(f, "", lbl, "name")
    end

    def recommendation(docxml)
      docxml.xpath(ns("//recommendation")).each do |f|
        recommendation1(f, @recommendation_lbl)
      end
    end

    def requirement(docxml)
      docxml.xpath(ns("//requirement")).each do |f|
        recommendation1(f, @requirement_lbl)
      end
    end

    def permission(docxml)
      docxml.xpath(ns("//permission")).each do |f|
        recommendation1(f, @permission_lbl)
      end
    end

    # introduce name element
    def recommendation1(f, type)
      n = @xrefs.anchor(f['id'], :label, false)
      lbl = (n.nil? ? type : l10n("#{type} #{n}"))
      prefix_name(f, "", lbl, "name")
    end

    def table(docxml)
      docxml.xpath(ns("//table")).each do |f|
        table1(f)
      end
    end

    def table1(f)
      return if labelled_ancestor(f)
      n = @xrefs.anchor(f['id'], :label, false)
      prefix_name(f, "&nbsp;&mdash; ", l10n("#{@table_lbl} #{n}"), "name")
    end
  end
end
