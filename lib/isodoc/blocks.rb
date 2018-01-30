module IsoDoc
  #module Blocks
    @@termdomain = ""
    @@termexample = false
    @@note = false
    @@sourcecode = false

    def self.set_termdomain(termdomain)
      @@termdomain = termdomain
    end

    def self.get_termexample
      @@termexample
    end

    def self.set_termexample(value)
      @@termexample = value
    end

    def self.in_sourcecode
      @@sourcecode
    end

    def self.is_note
      @@note
    end

    def self.note_p_parse(node, div)
      div.p **{ class: "Note" } do |p|
        p << "NOTE"
        insert_tab(p, 1)
        node.first_element_child.children.each { |n| parse(n, p) }
      end
      node.element_children[1..-1].each { |n| parse(n, div) }
    end

    def self.note_parse(node, out)
      @@note = true
      out.div **{ id: node["id"], class: "Note" } do |div|
        if node.first_element_child.name == "p"
          note_p_parse(node, div)
        else
          div.p **{ class: "Note" } do |p|
            p << "NOTE"
            insert_tab(p, 1)
          end
          node.children.each { |n| parse(n, div) }
        end
      end
      @@note = false
    end

    def self.figure_name_parse(node, div, name)
      div.p **{ class: "FigureTitle", align: "center" } do |p|
        p.b do |b|
          b << "#{get_anchors()[node['id']][:label]}&nbsp;&mdash; "
          b << name.text
        end
      end
    end

    def self.figure_key(out)
      out.p do |p| 
        p.b { |b| b << "Key" }
      end
    end

    def self.figure_parse(node, out)
      name = node.at(ns("./name"))
      out.div **attr_code(id: node["id"]) do |div|
        node.children.each do |n|
          figure_key(out) if n.name == "dl"
          parse(n, div) unless n.name == "name"
        end
        figure_name_parse(node, div, name) if name
      end
    end

    def self.sourcecode_name_parse(node, div, name)
      div.p **{ class: "FigureTitle", align: "center" } do |p|
        p.b do |b|
          b << name.text
        end
      end
    end

    def self.sourcecode_parse(node, out)
      name = node.at(ns("./name"))
      out.p **attr_code(id: node["id"], class: "Sourcecode") do |div|
        @@sourcecode = true
        node.children.each do |n|
          parse(n, div) unless n.name == "name"
        end
        @@sourcecode = false
        sourcecode_name_parse(node, div, name) if name
      end
    end

    def self.annotation_parse(node, out)
      out.p **{ class: "Sourcecode" } do |li|
        node.children.each { |n| parse(n, li) }
      end
    end

    def self.admonition_parse(node, out)
      name = node["type"]
      out.div **{ class: "Admonition" } do |t|
        t.p.b { |b| b << name.upcase } if name
        node.children.each do |n|
          parse(n, t)
        end
      end
    end

    def self.formula_parse(node, out)
      dl = node.at(ns("./dl"))
      out.div **attr_code(id: node["id"], class: "formula") do |div|
        parse(node.at(ns("./stem")), out)
        insert_tab(div, 1)
        div << "(#{get_anchors()[node['id']][:label]})"
      end
      if dl
        out.p { |p| p << "where" }
        parse(dl, out) 
      end
    end

    def self.para_attrs(node)
      classtype = nil
      classtype = "Note" if @@note
      classtype = "MsoFootnoteText" if in_footnote
      attrs = { class: classtype }
      unless node["align"].nil?
        attrs[:align] = node["align"] unless node["align"] == "justify"
        attrs[:style] = "text-align:#{node["align"]}"
      end
      attrs
    end

    def self.para_parse(node, out)
      out.p **attr_code(para_attrs(node)) do |p|
        unless @@termdomain.empty?
          p << "&lt;#{@@termdomain}&gt; "
          @@termdomain = ""
        end
        node.children.each { |n| parse(n, p) }
      end
    end

    def self.quote_attribution(node, out)
      author = node.at(ns("./author/fullname/"))
      source = node.at(ns("./source"))
      # TODO implement
    end

    def self.quote_parse(node, out)
      attrs = para_attrs(node)
      attrs[:class] = "Quote"
      out.p **attr_code(attrs) do |p|
        node.children.each do 
          |n| parse(n, p) unless ["author", "source"].include? n.name
        end
        quote_attribution(node, out)
      end
    end

    def self.image_title_parse(out, caption)
      unless caption.nil?
        out.p **{ class: "FigureTitle", align: "center" } do |p|
          p.b { |b| b << caption.to_s }
        end
      end
    end

    def self.image_parse(url, out, caption)
      out.img **attr_code(src: url)
      image_title_parse(out, caption)
    end
  end
#end
