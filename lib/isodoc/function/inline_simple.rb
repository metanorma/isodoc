module IsoDoc
  module Function
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

      def hr_parse(_node, out)
        out.hr
      end

      def br_parse(_node, out)
        out.br
      end

      def index_parse(node, out); end

      def index_xref_parse(node, out); end

      def bookmark_parse(node, out)
        out.a **attr_code(id: node["id"])
      end

      def keyword_parse(node, out)
        out.span class: "keyword" do |s|
          children_parse(node, s)
        end
      end

      def em_parse(node, out)
        out.i do |e|
          children_parse(node, e)
        end
      end

      def strong_parse(node, out)
        out.b do |e|
          children_parse(node, e)
        end
      end

      def sup_parse(node, out)
        out.sup do |e|
          children_parse(node, e)
        end
      end

      def sub_parse(node, out)
        out.sub do |e|
          children_parse(node, e)
        end
      end

      def tt_parse(node, out)
        out.tt do |e|
          children_parse(node, e)
        end
      end

      def strike_parse(node, out)
        out.s do |e|
          children_parse(node, e)
        end
      end

      def underline_parse(node, out)
        node["style"] and style = "text-decoration: #{node['style']}"
        out.u **attr_code(style: style) do |e|
          children_parse(node, e)
        end
      end

      def location_parse(node, out); end
      def author_parse(node, out); end
      def xref_label_parse(node, out); end
      def name_parse(node, out); end
      def semx_definition_parse(node, out); end
      def semx_xref_parse(node, out); end
      def semx_eref_parse(node, out); end
      def semx_link_parse(node, out); end
      def semx_origin_parse(node, out); end
      def date_parse(node, out); end
      def semx_stem_parse(node, out); end
      def floating_title_parse(node, out); end
      def identifier_parse(node, out); end
      def concept_parse(node, out); end
      def erefstack_parse(node, out); end
      def svgmap_parse(node, out); end
      def amend_parse(node, out); end
      def semx_sourcecode_parse(node, out); end
      def annotation_note_parse(node, out); end
      def semx_source_parse(node, out); end
    end
  end
end
