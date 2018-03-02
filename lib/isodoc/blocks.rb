module IsoDoc
  class Convert
    #attr_accessor :termdomain, :termexample, :sourcecode, :note
    def set_termdomain(termdomain)
      @termdomain = termdomain
    end

    def get_termexample
      @termexample
    end

    def set_termexample(value)
      @termexample = value
    end

    def in_sourcecode
      @sourcecode
    end

    def is_note
      @note
    end

    def note_label(node)
      n = get_anchors()[node["id"]]
      return "NOTE" if n.nil? || n[:label].empty?
      "NOTE #{n[:label]}"
    end

    def note_p_parse(node, div)
      div.p **{ class: "Note" } do |p|
        p << note_label(node)
        insert_tab(p, 1)
        node.first_element_child.children.each { |n| parse(n, p) }
      end
      node.element_children[1..-1].each { |n| parse(n, div) }
    end

    def note_parse(node, out)
      @note = true
      out.div **{ id: node["id"], class: "Note" } do |div|
        if node.first_element_child.name == "p"
          note_p_parse(node, div)
        else
          div.p **{ class: "Note" } do |p|
            p << note_label(node)
            insert_tab(p, 1)
          end
          node.children.each { |n| parse(n, div) }
        end
      end
      @note = false
    end

    def figure_name_parse(node, div, name)
      div.p **{ class: "FigureTitle", align: "center" } do |p|
        p.b do |b|
          b << "Figure #{get_anchors()[node['id']][:label]}"
          b << "&nbsp;&mdash; #{name.text}" if name
        end
      end
    end

    def figure_key(out)
      out.p do |p| 
        p.b { |b| b << "Key" }
      end
    end

    def figure_parse(node, out)
      @in_figure = true
      name = node.at(ns("./name"))
      out.div **attr_code(id: node["id"], class: "figure") do |div|
        node.children.each do |n|
          figure_key(out) if n.name == "dl"
          parse(n, div) unless n.name == "name"
        end
        figure_name_parse(node, div, name) if name
      end
      @in_figure = false
    end

    def example_label(node)
      n = get_anchors()[node["id"]]
      return "EXAMPLE" if n.nil? || n[:label].empty?
      "EXAMPLE #{n[:label]}"
    end

    def example_parse(node, out)
      name = node.at(ns("./name"))
=begin
      out.div **attr_code(id: node["id"], class: "example") do |div|
        out.p { |p| p << example_label(node) }
        node.children.each do |n|
          parse(n, div)
        end
      end
=end
      out.table **attr_code(id: node["id"], class: "example") do |t|
        t.tr do |tr|
          tr.td **{width: "75pt", valign: "top"} do |td|
            td << example_label(node)
          end
          tr.td **{valign: "top"} do |td|
            node.children.each do |n|
              parse(n, td)
            end
          end
        end
      end
    end

    def sourcecode_name_parse(node, div, name)
      div.p **{ class: "FigureTitle", align: "center" } do |p|
        p.b do |b|
          b << name.text
        end
      end
    end

    def sourcecode_parse(node, out)
      name = node.at(ns("./name"))
      out.p **attr_code(id: node["id"], class: "Sourcecode") do |div|
        @sourcecode = true
        node.children.each do |n|
          parse(n, div) unless n.name == "name"
        end
        @sourcecode = false
        sourcecode_name_parse(node, div, name) if name
      end
    end

    def annotation_parse(node, out)
      out.p **{ class: "Sourcecode" } do |li|
        node.children.each { |n| parse(n, li) }
      end
    end

    def admonition_parse(node, out)
      name = node["type"]
      out.div **{ class: "Admonition" } do |t|
        t.title { |b| b << name.upcase } if name
        node.children.each do |n|
          parse(n, t)
        end
      end
    end

    def formula_where(dl, out)
      out.p { |p| p << "where" }
      parse(dl, out)
    end

    def formula_parse(node, out)
      dl = node.at(ns("./dl"))
      out.div **attr_code(id: node["id"], class: "formula") do |div|
        parse(node.at(ns("./stem")), out)
        insert_tab(div, 1)
        div << "(#{get_anchors()[node['id']][:label]})"
      end
      formula_where(dl, out) if dl
    end

    def para_attrs(node)
      classtype = nil
      classtype = "Note" if @note
      # classtype = "MsoFootnoteText" if in_footnote
      classtype = "MsoCommentText" if in_comment
      attrs = { class: classtype, id: node["id"] }
      unless node["align"].nil?
        attrs[:align] = node["align"] unless node["align"] == "justify"
        attrs[:style] = "text-align:#{node["align"]}"
      end
      attrs
    end

    def para_parse(node, out)
      out.p **attr_code(para_attrs(node)) do |p|
        unless @termdomain.empty?
          p << "&lt;#{@termdomain}&gt; "
          @termdomain = ""
        end
        node.children.each { |n| parse(n, p) }
      end
    end

    def quote_attribution(node, out)
      author = node.at(ns("./author"))
      source = node.at(ns("./source"))
      out.p **{ class: "QuoteAttribution" } do |p|
        p << "&mdash; #{author.text}, " if author
        eref_parse(source, p) if source
      end
    end

    def quote_parse(node, out)
      attrs = para_attrs(node)
      attrs[:class] = "Quote"
      out.div **attr_code(attrs) do |p|
        node.children.each do 
          |n| parse(n, p) unless ["author", "source"].include? n.name
        end
        quote_attribution(node, out)
      end
    end

    def image_title_parse(out, caption)
      unless caption.nil?
        out.p **{ class: "FigureTitle", align: "center" } do |p|
          p.b { |b| b << caption.to_s }
        end
      end
    end

    def image_parse(url, out, caption)
      out.img **attr_code(src: url)
      image_title_parse(out, caption)
    end
  end
end
