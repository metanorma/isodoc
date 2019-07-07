require "fileutils"
require "pathname"

module IsoDoc::Function
  module ToWordHtml

    def set_termdomain(termdomain)
      @termdomain = termdomain
    end

    def in_sourcecode
      @sourcecode
    end

    def note?
      @note
    end

    def init_file(filename, debug)
      filepath = Pathname.new(filename)
      filename = filepath.sub_ext('').to_s
      dir = "#{filename}_files"
      unless debug
        Dir.mkdir(dir) unless File.exists?(dir)
        FileUtils.rm_rf "#{dir}/*"
      end
      @filename = filename
      @localdir = filepath.parent.to_s + '/'
      [filename, dir]
    end

    # tmp image dir is same directory as @filename
    def tmpimagedir
      @filename + tmpimagedir_suffix
    end

    def rel_tmpimagedir
      Pathname.new(@filename).basename.to_s + tmpimagedir_suffix
    end

    # isodoc.css overrides any CSS injected by Html2Doc, which
    # is inserted before this CSS.
    def define_head(html, filename, _dir)
      html.head do |head|
        #head.title { |t| t << filename }
        if @standardstylesheet
          head.style do |style|
            stylesheet = File.read(@standardstylesheet, encoding: "utf-8").
              gsub("FILENAME", File.basename(filename))
            style.comment "\n#{stylesheet}\n"
          end
        end
      end
    end

    def make_body(xml, docxml)
      body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72" }
      xml.body **body_attr do |body|
        make_body1(body, docxml)
        make_body2(body, docxml)
        make_body3(body, docxml)
      end
    end

    def make_body1(body, _docxml)
      body.div **{ class: "title-section" } do |div1|
        div1.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body2(body, docxml)
      body.div **{ class: "prefatory-section" } do |div2|
        div2.p { |p| p << "&nbsp;" } # placeholder
      end
      section_break(body)
    end

    def make_body3(body, docxml)
      body.div **{ class: "main-section" } do |div3|
        abstract docxml, div3
        foreword docxml, div3
        introduction docxml, div3
        middle docxml, div3
        footnotes div3
        comments div3
      end
    end

    def info(isoxml, out)
      @meta.title isoxml, out
      @meta.subtitle isoxml, out
      @meta.docstatus isoxml, out
      @meta.docid isoxml, out
      @meta.doctype isoxml, out
      @meta.author isoxml, out
      @meta.bibdate isoxml, out
      @meta.relations isoxml, out
      @meta.version isoxml, out
      @meta.url isoxml, out
      @meta.get
    end

    def middle_title(out)
      out.p(**{ class: "zzSTDTitle1" }) { |p| p << @meta.get[:doctitle] }
    end

    def middle(isoxml, out)
      middle_title(out)
      i = scope isoxml, out, 0
      i = norm_ref isoxml, out, i
      i = terms_defs isoxml, out, i
      i = symbols_abbrevs isoxml, out, i
      clause isoxml, out
      annex isoxml, out
      bibliography isoxml, out
    end

    def smallcap_parse(node, xml)
      xml.span **{ style: "font-variant:small-caps;" } do |s|
        #s << node.inner_html
        node.children.each { |n| parse(n, s) }
      end
    end

    def text_parse(node, out)
      return if node.nil? || node.text.nil?
      text = node.to_s
      text = text.gsub("\n", "<br/>").gsub("<br/> ", "<br/>&nbsp;").
        gsub(/[ ](?=[ ])/, "&nbsp;") if in_sourcecode
      out << text
    end

    def bookmark_parse(node, out)
      out.a **attr_code(id: node["id"])
    end

    def keyword_parse(node, out)
      out.span **{ class: "keyword" } do |s|
        #s << node.inner_html
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

    def parse(node, out)
      if node.text?
        text_parse(node, out)
      else
        case node.name
        when "em" then em_parse(node, out)
        when "strong" then strong_parse(node, out)
        when "sup" then sup_parse(node, out)
        when "sub" then sub_parse(node, out)
        when "tt" then tt_parse(node, out)
        when "strike" then strike_parse(node, out)
        when "keyword" then keyword_parse(node, out)
        when "smallcap" then smallcap_parse(node, out)
        when "br" then out.br
        when "hr" then out.hr
        when "bookmark" then bookmark_parse(node, out)
        when "pagebreak" then page_break(out)
        when "callout" then callout_parse(node, out)
        when "stem" then stem_parse(node, out)
        when "clause" then clause_parse(node, out)
        #when "appendix" then clause_parse(node, out)
        when "xref" then xref_parse(node, out)
        when "eref" then eref_parse(node, out)
        when "origin" then eref_parse(node, out)
        when "link" then link_parse(node, out)
        when "ul" then ul_parse(node, out)
        when "ol" then ol_parse(node, out)
        when "li" then li_parse(node, out)
        when "dl" then dl_parse(node, out)
        when "fn" then footnote_parse(node, out)
        when "p" then para_parse(node, out)
        when "quote" then quote_parse(node, out)
        when "tr" then tr_parse(node, out)
        when "note" then note_parse(node, out)
        when "review" then review_note_parse(node, out)
        when "admonition" then admonition_parse(node, out)
        when "formula" then formula_parse(node, out)
        when "table" then table_parse(node, out)
        when "figure" then figure_parse(node, out)
        when "example" then example_parse(node, out)
        when "image" then image_parse(node, out, nil)
        when "sourcecode" then sourcecode_parse(node, out)
        when "pre" then pre_parse(node, out)
        when "annotation" then annotation_parse(node, out)
        when "term" then termdef_parse(node, out)
        when "preferred" then term_parse(node, out)
        when "admitted" then admitted_term_parse(node, out)
        when "deprecates" then deprecated_term_parse(node, out)
        when "domain" then set_termdomain(node.text)
        when "definition" then definition_parse(node, out)
        when "termsource" then termref_parse(node, out)
        when "modification" then modification_parse(node, out)
        when "termnote" then termnote_parse(node, out)
        when "termexample" then example_parse(node, out)
        when "terms" then terms_parse(node, out)
        when "definitions" then symbols_parse(node, out)
        when "references" then bibliography_parse(node, out)
        when "termdocsource" then termdocsource_parse(node, out)
        when "requirement" then requirement_parse(node, out)
        when "recommendation" then recommendation_parse(node, out)
        when "permission" then permission_parse(node, out)
        when "subject" then requirement_skip_parse(node, out)
        when "classification" then requirement_skip_parse(node, out)
        when "inherit" then requirement_component_parse(node, out)
        when "description" then requirement_component_parse(node, out)
        when "specification" then requirement_component_parse(node, out)
        when "measurement-target" then requirement_component_parse(node, out)
        when "verification" then requirement_component_parse(node, out)
        when "import" then requirement_component_parse(node, out)
        else
          error_parse(node, out)
        end
      end
    end
  end
end
