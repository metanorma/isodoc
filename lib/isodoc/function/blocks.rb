module IsoDoc::Function
  module Blocks
    @annotation = false

    def note_label(node)
      n = get_anchors[node["id"]]
      return @note_lbl if n.nil? || n[:label].nil? || n[:label].empty?
      l10n("#{@note_lbl} #{n[:label]}")
    end

    def note_p_parse(node, div)
      div.p do |p|
        p.span **{ class: "note_label" } do |s|
          s << note_label(node)
        end
        insert_tab(p, 1)
        node.first_element_child.children.each { |n| parse(n, p) }
      end
      node.element_children[1..-1].each { |n| parse(n, div) }
    end

    def note_parse1(node, div)
      div.p do |p|
        p.span **{ class: "note_label" } do |s|
          s << note_label(node)
        end
        insert_tab(p, 1)
      end
      node.children.each { |n| parse(n, div) }
    end

    def note_parse(node, out)
      @note = true
      out.div **{ id: node["id"], class: "Note" } do |div|
        if node.first_element_child.name == "p"
          note_p_parse(node, div)
        else
          note_parse1(node, div)
        end
      end
      @note = false
    end

    def figure_name_parse(node, div, name)
      return if name.nil? && node.at(ns("./figure"))
      div.p **{ class: "FigureTitle", align: "center" } do |p|
        lbl = anchor(node['id'], :label, false)
        lbl.nil? or p << l10n("#{@figure_lbl} #{lbl}")
        name and !lbl.nil? and p << "&nbsp;&mdash; "
=begin
        get_anchors[node['id']][:label].nil? or
          p << l10n("#{@figure_lbl} #{get_anchors[node['id']][:label]}")
        name and !get_anchors[node['id']][:label].nil? and
          p << "&nbsp;&mdash; "
=end
        name and name.children.each { |n| parse(n, div) }
      end
    end

    def figure_key(out)
      out.p do |p|
        p.b { |b| b << @key_lbl }
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
        figure_name_parse(node, div, name)
      end
      @in_figure = false
    end

    def example_label(node)
      n = get_anchors[node["id"]]
      return @example_lbl if n.nil? || n[:label].nil? || n[:label].empty?
      l10n("#{@example_lbl} #{n[:label]}")
    end

    EXAMPLE_TBL_ATTR =
      { valign: "top", class: "example_label",
        style: "width:82.8pt;padding:0 0 0 0;margin-left:0pt" }.freeze

    # used if we are boxing examples
    def example_div_parse(node, out)
      out.div **attr_code(id: node["id"], class: "example") do |div|
        div.p **{ class: "example-title" } do |p|
          p << example_label(node)
        end
        node.children.each do |n|
          parse(n, div)
        end
      end
    end

    def example_table_attr(node)
      attr_code(id: node["id"], class: "example",
                cellspacing: 0, cellpadding: 0,
                style: "border-collapse:collapse" )
    end

    def example_table_parse(node, out)
      out.table **example_table_attr(node) do |t|
        t.tr do |tr|
          tr.td **EXAMPLE_TBL_ATTR do |td|
            td << example_label(node)
          end
          tr.td **{ valign: "top", class: "example" } do |td|
            node.children.each { |n| parse(n, td) }
          end
        end
      end
    end

    def example_parse(node, out)
      example_div_parse(node, out)
    end

    def sourcecode_name_parse(_node, div, name)
      div.p **{ class: "SourceTitle", align: "center" } do |p|
        name.children.each { |n| parse(n, p) }
      end
    end

    def admonition_name_parse(_node, div, name)
      div.p **{ class: "AdmonitionTitle", align: "center" } do |p|
        name.children.each { |n| parse(n, p) }
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

    def pre_parse(node, out)
      out.pre node.text, **attr_code(id: node["id"])
    end

    def annotation_parse(node, out)
      @sourcecode = false
      @annotation = true
      out.span **{ class: "zzMoveToFollowing" } do |s|
        s  << "&lt;#{node.at(ns("//callout[@target='#{node['id']}']")).text}&gt; "
      end
      node.children.each { |n| parse(n, out) }
      @annotation = false
    end

    def admonition_class(node)
      "Admonition"
    end

    def admonition_name(node, type)
      name = node&.at(ns("./name")) and return name
      name = Nokogiri::XML::Node.new('name', node.document)
      return unless type && @admonition[type]
      name << @admonition[type]&.upcase
      name
    end

    def admonition_parse(node, out)
      type = node["type"]
      name = admonition_name(node, type)
      out.div **{ class: admonition_class(node) } do |t|
        admonition_name_parse(node, t, name) if name
        node.children.each do |n|
          parse(n, t) unless n.name == "name"
        end
      end
    end

    def formula_where(dl, out)
      return unless dl
      out.p { |p| p << @where_lbl }
      parse(dl, out)
    end

    def formula_parse1(node, out)
      out.div **attr_code(id: node["id"], class: "formula") do |div|
        div.p do |p|
          parse(node.at(ns("./stem")), div)
          lbl = anchor(node['id'], :label, false)
          #unless get_anchors[node['id']][:label].nil?
          unless lbl.nil?
            insert_tab(div, 1)
            #div << "(#{get_anchors[node['id']][:label]})"
            div << "(#{lbl})"
          end
        end
      end
    end

    def formula_parse(node, out)
      formula_parse1(node, out)
      formula_where(node.at(ns("./dl")), out)
      node.children.each do |n|
        next if %w(stem dl).include? n.name
        parse(n, out)
      end
    end

    def para_class(_node)
      classtype = nil
      classtype = "MsoCommentText" if in_comment
      classtype = "Sourcecode" if @annotation
      classtype
    end

    def para_attrs(node)
      attrs = { class: para_class(node), id: node["id"] }
      unless node["align"].nil?
        attrs[:align] = node["align"] unless node["align"] == "justify"
        attrs[:style] = "text-align:#{node['align']}"
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
        p << "&mdash; #{author.text}" if author
        p << ", " if author && source
        eref_parse(source, p) if source
      end
    end

    def quote_parse(node, out)
      attrs = para_attrs(node)
      attrs[:class] = "Quote"
      out.div **attr_code(attrs) do |p|
        node.children.each do |n|
          parse(n, p) unless ["author", "source"].include? n.name
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

    def image_parse(node, out, caption)
      attrs = { src: node["src"],
                height: node["height"] || "auto",
                width: node["width"] || "auto",
                alt: node["alt"]  }
      out.img **attr_code(attrs)
      image_title_parse(out, caption)
    end

    def recommendation_name(node, out, type)
      label = node.at(ns("./label"))
      title = node.at(ns("./title"))
      out.p **{ class: "AdmonitionTitle" }  do |b|
        lbl = anchor(node['id'], :label, false)
        lbl.nil? or b << l10n("#{type} #{lbl}:")
        #get_anchors[node['id']][:label].nil? or
        #b << l10n("#{type} #{get_anchors[node['id']][:label]}:")
        if label || title
          b.br
          label and label.children.each { |n| parse(n,b) }
          b << "#{clausedelim} " if label && title
          title and title.children.each { |n| parse(n,b) }
        end
      end
    end

    def recommendation_parse(node, out)
      out.div **{ class: "recommend" } do |t|
        recommendation_name(node, t, @recommendation_lbl)
        node.children.each do |n|
          parse(n, t) unless %w(label title).include? n.name
        end
      end
    end

    def requirement_parse(node, out)
      out.div **{ class: "require" } do |t|
        recommendation_name(node, t, @requirement_lbl)
        node.children.each do |n|
          parse(n, t) unless %w(label title).include? n.name
        end
      end
    end

    def permission_parse(node, out)
      out.div **{ class: "permission" } do |t|
        recommendation_name(node, t, @permission_lbl)
        node.children.each do |n|
          parse(n, t) unless %w(label title).include? n.name
        end
      end
    end

    def requirement_component_parse(node, out)
      return if node["exclude"] == "true"
      out.div **{ class: "requirement-" + node.name } do |div|
        node.children.each do |n|
          parse(n, div)
        end
      end
    end

    def requirement_skip_parse(node, out)
    end
  end
end
