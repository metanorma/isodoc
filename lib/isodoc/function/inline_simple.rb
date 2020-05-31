module IsoDoc::Function
  module Inline
    def section_break(body)
      body.br
    end

    def page_break(out)
      out.br
    end

    def pagebreak_parse(_node, out)
      out.br
    end

    def hr_parse(node, out)
      out.hr
    end

    def br_parse(node, out)
      out.br
    end

    def index_parse(node, out)
    end

        def bookmark_parse(node, out)
      out.a **attr_code(id: node["id"])
    end

    def keyword_parse(node, out)
      out.span **{ class: "keyword" } do |s|
        node.children.each { |n| parse(n, s) }
      end
    end

    def em_parse(node, out)
      out.i do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def strong_parse(node, out)
      out.b do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def sup_parse(node, out)
      out.sup do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def sub_parse(node, out)
      out.sub do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def tt_parse(node, out)
      out.tt do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def strike_parse(node, out)
      out.s do |e|
        node.children.each { |n| parse(n, e) }
      end
    end
  end
end
