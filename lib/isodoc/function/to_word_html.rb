require "fileutils"
require "pathname"
require_relative "setup"

module IsoDoc
  module Function
    module ToWordHtml
      # isodoc.css overrides any CSS injected by Html2Doc, which
      # is inserted before this CSS.
      def define_head(head, _filename, _dir)
        if @standardstylesheet
          head.style do |style|
            @standardstylesheet.open
            stylesheet = @standardstylesheet.read
            style.comment "\n#{stylesheet}\n"
          end
        end
      end

      def body_attr
        { lang: @lang.to_s }
      end

      def make_body(xml, docxml)
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      def make_body1(body, _docxml)
        body.div class: "title-section" do |div1|
          div1.p { |p| p << "&#xa0;" } # placeholder
        end
        section_break(body)
      end

      def make_body2(body, _docxml)
        body.div class: "prefatory-section" do |div2|
          div2.p { |p| p << "&#xa0;" } # placeholder
        end
        section_break(body)
      end

      TOP_ELEMENTS =
        "//preface/*[@displayorder] | //sections/*[@displayorder] | " \
        "//annex[@displayorder] | //bibliography/*[@displayorder] | " \
        "//colophon/*[@displayorder] | //indexsect[@displayorder]"
          .freeze

      def make_body3(body, docxml)
        body.div class: "main-section" do |div3|
          boilerplate docxml, div3
          content(div3, docxml, ns(self.class::TOP_ELEMENTS))
          footnotes docxml, div3
          comments docxml, div3
        end
      end

      # xpath presumed to list elements with displayorder attribute
      def content(body, docxml, xpath)
        docxml.xpath(xpath).sort_by { |c| c["displayorder"].to_i }
          .each do |c|
            top_element_render(c, body)
          end
      end

      def top_element_render(e, out)
        case e.name
        when "abstract" then abstract e, out
        when "foreword" then foreword e, out
        when "introduction" then introduction e, out
        when "executivesummary" then executivesummary e, out
        when "acknowledgements" then acknowledgements e, out
        when "annex" then annex e, out
        when "appendix" then appendix e, out
        when "definitions" then symbols_abbrevs e, out
        when "indexsect" then indexsect e, out
        when "references"
          if e["normative"] == "true" then norm_ref e, out
          else bibliography e, out
          end
        when "clause"
          if e.parent.name == "preface" then preface e, out
          elsif e.parent.name == "colophon" then colophon e, out
          elsif e["type"] == "scope" then scope e, out
          elsif e.at(ns(".//terms")) then terms_defs e, out
          elsif e.at(ns(".//references[@normative = 'true']"))
            norm_ref e, out
          elsif e.at(ns(".//references")) then bibliography e, out
          else clause e, out
          end
        else parse(e, out)
        end
      end

      def cross_align(isoxml, out)
        isoxml.xpath(ns("//cross-align")).each do |c|
          parse(c, out)
        end
      end

      def boilerplate(node, out)
        @bare and return
        boilerplate = node.at(ns("//boilerplate")) or return
        out.div class: "authority" do |s|
          boilerplate.children.each do |n|
            if n.name == "title"
              s.h1 do |h|
                n.children.each { |nn| parse(nn, h) }
              end
            else parse(n, s)
            end
          end
        end
      end

      def parse(node, out)
        if node.text? then text_parse(node, out)
        else
          case node.name
          when "em" then em_parse(node, out)
          when "strong" then strong_parse(node, out)
          when "sup" then sup_parse(node, out)
          when "sub" then sub_parse(node, out)
          when "tt" then tt_parse(node, out)
          when "strike" then strike_parse(node, out)
          when "underline" then underline_parse(node, out)
          when "keyword" then keyword_parse(node, out)
          when "smallcap" then smallcap_parse(node, out)
          when "br" then br_parse(node, out)
          when "hr" then hr_parse(node, out)
          when "bookmark" then bookmark_parse(node, out)
          when "pagebreak" then pagebreak_parse(node, out)
          when "callout" then callout_parse(node, out)
          when "fmt-stem" then stem_parse(node, out)
          when "stem" then semx_stem_parse(node, out)
          when "clause" then clause_parse(node, out)
          when "appendix" then appendix_parse(node, out)
          when "xref" then semx_xref_parse(node, out)
          when "fmt-xref" then xref_parse(node, out)
          when "eref" then semx_eref_parse(node, out)
          when "fmt-eref" then eref_parse(node, out)
          when "origin" then semx_origin_parse(node, out)
          when "fmt-origin" then origin_parse(node, out)
          when "link" then semx_link_parse(node, out)
          when "fmt-link" then link_parse(node, out)
          when "ul" then ul_parse(node, out)
          when "ol" then ol_parse(node, out)
          when "li" then li_parse(node, out)
          when "dl" then dl_parse(node, out)
          when "fn" then footnote_parse(node, out)
          when "p" then para_parse(node, out)
          when "quote" then quote_parse(node, out)
          when "source" then semx_source_parse(node, out)
          when "fmt-source" then source_parse(node, out)
          when "tr" then tr_parse(node, out)
          when "note" then note_parse(node, out)
          when "annotation" then annotation_note_parse(node, out)
          when "admonition" then admonition_parse(node, out)
          when "formula" then formula_parse(node, out)
          when "table" then table_parse(node, out)
          when "figure" then figure_parse(node, out)
          when "example", "termexample" then example_parse(node, out)
          when "image" then image_parse(node, out, nil)
          when "sourcecode" then sourcecode_parse(node, out)
          when "pre" then pre_parse(node, out)
          when "annotation" then annotation_parse(node, out)
          when "term" then termdef_parse(node, out)
          when "preferred" then semx_term_parse(node, out)
          when "fmt-preferred" then term_parse(node, out)
          when "admitted" then semx_admitted_term_parse(node, out)
          when "fmt-admitted" then admitted_term_parse(node, out)
          when "deprecates" then semx_deprecated_term_parse(node, out)
          when "fmt-deprecates" then deprecated_term_parse(node, out)
          when "domain" then termdomain_parse(node, out)
          when "definition" then semx_definition_parse(node, out)
          when "fmt-definition" then definition_parse(node, out)
          when "termsource" then semx_termref_parse(node, out)
          when "fmt-termsource" then termref_parse(node, out)
          when "related" then semx_related_parse(node, out)
          when "modification" then modification_parse(node, out)
          when "termnote" then termnote_parse(node, out)
          when "terms" then terms_parse(node, out)
          when "definitions" then symbols_parse(node, out)
          when "references" then bibliography_parse(node, out)
          when "termdocsource" then termdocsource_parse(node, out)
          when "requirement" then requirement_parse(node, out)
          when "recommendation" then recommendation_parse(node, out)
          when "permission" then permission_parse(node, out)
          when "div" then div_parse(node, out)
          when "index" then index_parse(node, out)
          when "index-xref" then index_xref_parse(node, out)
          when "termref" then termrefelem_parse(node, out)
          when "copyright-statement" then copyright_parse(node, out)
          when "license-statement" then license_parse(node, out)
          when "legal-statement" then legal_parse(node, out)
          when "feedback-statement" then feedback_parse(node, out)
          when "passthrough" then passthrough_parse(node, out)
          when "tab" then clausedelimspace(node, out) # in Presentation XML only
          when "svg" then svg_parse(node, out) # in Presentation XML only
          when "add" then add_parse(node, out)
          when "del" then del_parse(node, out)
          when "form" then form_parse(node, out)
          when "input" then input_parse(node, out)
          when "select" then select_parse(node, out)
          when "label" then label_parse(node, out)
          when "option" then option_parse(node, out)
          when "textarea" then textarea_parse(node, out)
          when "toc" then toc_parse(node, out)
          when "title" then freestanding_title(node, out) # not inside clause
          when "variant-title" then variant_title(node, out)
          when "span" then span_parse(node, out)
          when "location" then location_parse(node, out)
          when "cross-align" then cross_align_parse(node, out)
          when "columnbreak" then columnbreak_parse(node, out)
          when "attribution" then attribution_parse(node, out)
          when "author" then author_parse(node, out)
          when "ruby" then ruby_parse(node, out)
          when "rt" then rt_parse(node, out)
          when "rb" then rb_parse(node, out)
          when "semx" then semx_parse(node, out)
          when "name" then name_parse(node, out)
          when "fmt-xref-label" then xref_label_parse(node, out)
          when "fmt-name" then fmt_name_parse(node, out)
          when "floating-title" then floating_title_parse(node, out)
          when "fmt-identifier" then fmt_identifier_parse(node, out)
          when "identifier" then identifier_parse(node, out)
          when "fmt-concept" then fmt_concept_parse(node, out)
          when "concept" then concept_parse(node, out)
          when "erefstack" then erefstack_parse(node, out)
          when "svgmap" then svgmap_parse(node, out)
          when "amend" then amend_parse(node, out)
          when "date" then date_parse(node, out)
          when "fmt-date" then fmt_date_parse(node, out)
          when "fmt-fn-body" then fmt_fn_body_parse(node, out)
          when "fmt-fn-label" then fmt_fn_label_parse(node, out)
          when "fmt-footnote-container" then fmt_footnote_container_parse(node, out)
          when "fmt-annotation-start" then fmt_annotation_start_parse(node, out)
          when "fmt-annotation-end" then fmt_annotation_end_parse(node, out)
          when "fmt-annotation-body" then fmt_annotation_body_parse(node, out)
          else error_parse(node, out)
          end
        end
      end
    end
  end
end
