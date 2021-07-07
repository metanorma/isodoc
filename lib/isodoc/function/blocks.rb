require_relative "blocks_example_note"

module IsoDoc::Function
  module Blocks
    @annotation = false

    def middle_title(_isoxml, out)
      out.p(**{ class: "zzSTDTitle1" }) { |p| p << @meta.get[:doctitle] }
    end

    def middle_admonitions(isoxml, out)
      isoxml.xpath(ns("//sections/note | //sections/admonition")).each do |x|
        parse(x, out)
      end
    end

    def figure_name_parse(_node, div, name)
      return if name.nil?

      div.p **{ class: "FigureTitle", style: "text-align:center;" } do |p|
        name.children.each { |n| parse(n, p) }
      end
    end

    def figure_key(out)
      out.p **{ style: "page-break-after:avoid;" } do |p|
        p.b { |b| b << @i18n.key }
      end
    end

    def figure_attrs(node)
      attr_code(id: node["id"], class: "figure", style: keep_style(node))
    end

    def figure_parse(node, out)
      return pseudocode_parse(node, out) if node["class"] == "pseudocode" ||
        node["type"] == "pseudocode"

      @in_figure = true
      out.div **figure_attrs(node) do |div|
        node.children.each do |n|
          figure_key(out) if n.name == "dl"
          parse(n, div) unless n.name == "name"
        end
        figure_name_parse(node, div, node.at(ns("./name")))
      end
      @in_figure = false
    end

    def pseudocode_attrs(node)
      attr_code(id: node["id"], class: "pseudocode", style: keep_style(node))
    end

    def pseudocode_parse(node, out)
      @in_figure = true
      name = node.at(ns("./name"))
      out.div **pseudocode_attrs(node) do |div|
        node.children.each { |n| parse(n, div) unless n.name == "name" }
        sourcecode_name_parse(node, div, name)
      end
      @in_figure = false
    end

    def sourcecode_name_parse(_node, div, name)
      return if name.nil?

      div.p **{ class: "SourceTitle", style: "text-align:center;" } do |p|
        name.children.each { |n| parse(n, p) }
      end
    end

    def admonition_name_parse(_node, div, name)
      div.p **{ class: "AdmonitionTitle", style: "text-align:center;" } do |p|
        name.children.each { |n| parse(n, p) }
      end
    end

    def sourcecode_attrs(node)
      attr_code(id: node["id"], class: "Sourcecode", style: keep_style(node))
    end

    def sourcecode_parse(node, out)
      name = node.at(ns("./name"))
      out.p **sourcecode_attrs(node) do |div|
        @sourcecode = true
        node.children.each { |n| parse(n, div) unless n.name == "name" }
        @sourcecode = false
      end
      sourcecode_name_parse(node, out, name)
    end

    def pre_parse(node, out)
      out.pre node.text, **attr_code(id: node["id"])
    end

    def annotation_parse(node, out)
      @sourcecode = false
      @annotation = true
      node.at("./preceding-sibling::*[local-name() = 'annotation']") or
        out << "<br/>"
      callout = node.at(ns("//callout[@target='#{node['id']}']"))
      out << "<br/>&lt;#{callout.text}&gt; "
      out << node&.children&.text&.strip
      @annotation = false
    end

    def admonition_class(_node)
      "Admonition"
    end

    def admonition_name(node, type)
      name = node&.at(ns("./name")) and return name
      name = Nokogiri::XML::Node.new("name", node.document)
      return unless type && @i18n.admonition[type]

      name << @i18n.admonition[type]&.upcase
      name
    end

    def admonition_attrs(node)
      attr_code(id: node["id"], class: admonition_class(node),
                style: keep_style(node))
    end

    def admonition_parse(node, out)
      type = node["type"]
      name = admonition_name(node, type)
      out.div **admonition_attrs(node) do |t|
        admonition_name_parse(node, t, name) if name
        node.children.each { |n| parse(n, t) unless n.name == "name" }
      end
    end

    def formula_where(dl, out)
      return unless dl

      out.p **{ style: "page-break-after:avoid;" } do |p|
        p << @i18n.where
      end
      parse(dl, out)
      out.parent.at("./dl")["class"] = "formula_dl"
    end

    def formula_parse1(node, out)
      out.div **attr_code(class: "formula") do |div|
        div.p do |_p|
          parse(node.at(ns("./stem")), div)
          if lbl = node&.at(ns("./name"))&.text
            insert_tab(div, 1)
            div << "(#{lbl})"
          end
        end
      end
    end

    def formula_attrs(node)
      attr_code(id: node["id"], style: keep_style(node))
    end

    def formula_parse(node, out)
      out.div **formula_attrs(node) do |div|
        formula_parse1(node, div)
        formula_where(node.at(ns("./dl")), div)
        node.children.each do |n|
          next if %w(stem dl name).include? n.name

          parse(n, div)
        end
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
      s = node["align"].nil? ? "" : "text-align:#{node['align']};"
      s = "#{s}#{keep_style(node)}"
      attrs[:style] = s unless s.empty?
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
      return if author.nil? && source.nil?

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

    def passthrough_parse(node, out)
      return if node["format"] &&
        !(node["format"].split(",").include? @format.to_s)

      out.passthrough node.text
    end

    def svg_parse(node, out)
      out.parent.add_child(node)
    end
  end
end
