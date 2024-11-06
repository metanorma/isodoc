require_relative "image"
require_relative "sourcecode"
require "rouge"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def lower2cap(text)
      /^[[:upper:]][[:upper:]]/.match?(text) and return text
      text&.capitalize
    end

    def block_delim
      "&#xa0;&#x2014; "
    end

    def prefix_name(node, delim, number, elem)
      number.nil? || number.empty? and return
      unless name = node.at(ns("./#{elem}"))
        node.add_first_child "<#{elem}></#{elem}>"
        name = node.children.first
      end
      if name.children.empty? then name.add_child(cleanup_entities(number.strip))
      else (name.children.first.previous = "#{number.strip}#{delim}")
      end
    end

    def formula(docxml)
      docxml.xpath(ns("//formula")).each { |f| formula1(f) }
    end

    def formula1(elem)
      formula_where(elem.at(ns("./dl")))
      lbl = @xrefs.anchor(elem["id"], :label, false)
      lbl.nil? || lbl.empty? or prefix_name(elem, "", "(#{lbl})", "name")
    end

    def formula_where(dlist)
      dlist or return
      dlist["class"] = "formula_dl"
      where = dlist.xpath(ns("./dt")).size > 1 ? @i18n.where : @i18n.where_one
      dlist.previous = "<p keep-with-next='true'>#{where}</p>"
    end

    def example(docxml)
      docxml.xpath(ns("//example")).each { |f| example1(f) }
    end

    def example1(elem)
      n = @xrefs.get[elem["id"]]
      lbl = if n.nil? || n[:label].nil? || n[:label].empty?
              @i18n.example
            else l10n("#{@i18n.example} #{n[:label]}")
            end
      prefix_name(elem, block_delim, lbl, "name")
    end

    def note(docxml)
      docxml.xpath(ns("//note")).each { |f| note1(f) }
    end

    def note_delim(_elem)
      ""
    end

    def note1(elem)
      %w(bibdata bibitem).include?(elem.parent.name) ||
        elem["notag"] == "true" and return
      lbl = note_label(elem)
      prefix_name(elem, "", lbl, "name")
    end

    def note_label(elem)
      n = @xrefs.get[elem["id"]]
      lbl = @i18n.note
      (n.nil? || n[:label].nil? || n[:label].empty?) or
        lbl = l10n("#{lbl} #{n[:label]}")
      "#{lbl}#{note_delim(elem)}"
    end

    def admonition(docxml)
      docxml.xpath(ns("//admonition")).each { |f| admonition1(f) }
    end

    def admonition1(elem)
      if elem["type"] == "box"
        admonition_numbered1(elem)
      elsif elem["notag"] == "true" || elem.at(ns("./name"))
      else
        label = admonition_label(elem, nil)
        prefix_name(elem, "", label, "name")
      end
      n = elem.at(ns("./name")) and n << admonition_delim(elem)
    end

    def admonition_numbered1(elem)
      elem["unnumbered"] && !elem.at(ns("./name")) and return
      label = admonition_label(elem, @xrefs.anchor(elem["id"], :label, false))
      prefix_name(elem, block_delim, label, "name")
    end

    def admonition_label(elem, num)
      lbl = if elem["type"] == "box" then @i18n.box
            else @i18n.admonition[elem["type"]]&.upcase end
      num and lbl = l10n("#{lbl} #{num}")
      lbl
    end

    def admonition_delim(_elem)
      ""
    end

    def table(docxml)
      table_long_strings_cleanup(docxml)
      docxml.xpath(ns("//table")).each { |f| table1(f) }
    end

    def table1(elem)
      labelled_ancestor(elem) and return
      elem["unnumbered"] && !elem.at(ns("./name")) and return
      n = @xrefs.anchor(elem["id"], :label, false)
      prefix_name(elem, block_delim, l10n("#{lower2cap @i18n.table} #{n}"),
                  "name")
    end

    def table_long_strings_cleanup(docxml)
      @break_up_urls_in_tables or return
      docxml.xpath(ns("//td | //th")).each do |d|
        d.traverse do |n|
          n.text? or next
          ret = Metanorma::Utils::break_up_long_str(n.text)
          n.content = ret
        end
      end
    end

    # we use this to eliminate the semantic amend blocks from rendering
    def amend(docxml)
      docxml.xpath(ns("//amend")).each { |f| amend1(f) }
    end

    def amend1(elem)
      elem.xpath(ns("./locality | ./localityStack | ./autonumber | " \
                    "./classification | ./contributor")).each(&:remove)
      elem.xpath(ns("./newcontent")).each { |a| a.name = "quote" }
      elem.xpath(ns("./description")).each { |a| a.replace(a.children) }
      elem.replace(elem.children)
    end

    def dl(docxml); end

    def ol(docxml)
      docxml.xpath(ns("//ol")).each { |f| ol1(f) }
      @xrefs.list_anchor_names(docxml.xpath(ns(@xrefs.sections_xpath)))
      docxml.xpath(ns("//ol/li")).each { |f| ol_label(f) }
    end

    # We don't really want users to specify type of ordered list;
    # we will use by default a fixed hierarchy as practiced by ISO (though not
    # fully spelled out): a) 1) i) A) I)
    def ol_depth(node)
      depth = node.ancestors("ul, ol").size + 1
      type = :alphabet
      type = :arabic if [2, 7].include? depth
      type = :roman if [3, 8].include? depth
      type = :alphabet_upper if [4, 9].include? depth
      type = :roman_upper if [5, 10].include? depth
      type
    end

    def ol1(elem)
      elem["type"] ||= ol_depth(elem).to_s
      elem.xpath(ns("./li")).each do |li|
        li["id"] ||= "_#{UUIDTools::UUID.random_create}"
      end
    end

    def ol_label(elem)
      elem["label"] = @xrefs.anchor(elem["id"], :label, false)
    end

    def source(docxml)
      docxml.xpath(ns("//source/modification")).each do |f|
        source_modification(f)
      end
      docxml.xpath(ns("//table/source")).each { |f| tablesource(f) }
      docxml.xpath(ns("//figure/source")).each { |f| figuresource(f) }
    end

    def tablesource(elem)
      source1(elem)
    end

    def figuresource(elem)
      source1(elem)
    end

    def source1(elem)
      while elem&.next_element&.name == "source"
        elem << "; #{to_xml(elem.next_element.remove.children)}"
      end
      elem.children = l10n("[#{@i18n.source}: #{to_xml(elem.children).strip}]")
    end

    def source_modification(mod)
      termsource_modification(mod.parent)
    end

    def quote(docxml)
      docxml.xpath(ns("//quote")).each { |f| quote1(f) }
    end

    def quote1(elem)
      author = elem.at(ns("./author"))
      source = elem.at(ns("./source"))
      author.nil? && source.nil? and return
      p = "&#x2014; "
      p += author.remove.to_xml if author
      p += ", " if author && source
      if source
        source.name = "eref"
        p += source.remove.to_xml
      end
      elem << "<attribution><p>#{l10n p}</p></attribution>"
    end
  end
end
