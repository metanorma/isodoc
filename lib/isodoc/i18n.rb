module IsoDoc
  class Convert

    TERM_DEF_BOILERPLATE = 
    case @lang
    "en":
    <<~BOILERPLATE.freeze
      <p>ISO and IEC maintain terminological databases for use in
      standardization at the following addresses:</p>

      <ul> 
      <li> <p>ISO Online browsing platform: available at
        <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
      <li> <p>IEC Electropedia: available at
        <a href="http://www.electropedia.org">http://www.electropedia.org</a>
      </p> </li> </ul>
    BOILERPLATE
    "zh":
    <<~BOILERPLATE.freeze
      <p>ISO and IEC maintain terminological databases for use in
      standardization at the following addresses:</p>

      <ul> 
      <li> <p>ISO在线浏览平台:
        <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
      <li> <p>IEC Electropedia: 
        <a href="http://www.electropedia.org">http://www.electropedia.org</a>
      </p> </li> </ul>
    BOILERPLATE
    else:
    <<~BOILERPLATE.freeze
      <p>ISO and IEC maintain terminological databases for use in
      standardization at the following addresses:</p>

      <ul> 
      <li> <p>ISO Online browsing platform: available at
        <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
      <li> <p>IEC Electropedia: available at
        <a href="http://www.electropedia.org">http://www.electropedia.org</a>
      </p> </li> </ul>
    BOILERPLATE

=begin
    def scope(isoxml, out)
      f = isoxml.at(ns("//clause[title = 'Scope']")) || return
      out.div **attr_code(id: f["id"]) do |div|
        clause_name("1.", "Scope", div, false, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
    end

    def term_defs_boilerplate(div, source, term)
      if source.empty? && term.nil?
        div << "<p>No terms and definitions are listed in this document.</p>"
      else
        out = "<p>For the purposes of this document, " +
          term_defs_boilerplate_cont(source, term)
        div << out
      end
      div << TERM_DEF_BOILERPLATE
    end

    def term_defs_boilerplate_cont(src, term)
      sources = sentence_join(src.map { |s| s["citeas"] })
      if src.empty?
        "the following terms and definitions apply.</p>"
      elsif term.nil?
        "the terms and definitions given in #{sources} apply.</p>"
      else
        "the terms and definitions given in #{sources} "\
          "and the following apply.</p>"
      end
    end

    def terms_defs_title(f)
      symbols = f.at(".//symbols-abbrevs")
      return "Terms, Definitions, Symbols and Abbreviated Terms" if symbols
      "Terms and Definitions"
    end

    def symbols_abbrevs(isoxml, out)
      f = isoxml.at(ns("//sections/symbols-abbrevs")) || return
      out.div **attr_code(id: f["id"], class: "Symbols") do |div|
        clause_name("4.", "Symbols and Abbreviated Terms", div, false, nil)
        f.elements.each do |e|
          parse(e, div) unless e.name == "title"
        end
      end
    end

    def introduction(isoxml, out)
      f = isoxml.at(ns("//introduction")) || return
      num = f.at(ns(".//subsection")) ? "0." : nil
      title_attr = { class: "IntroTitle" }
      page_break(out)
      out.div **{ class: "Section3", id: f["id"] } do |div|
        # div.h1 "Introduction", **attr_code(title_attr)
        clause_name(num, "Introduction", div, false, title_attr)
        f.elements.each do |e|
          if e.name == "patent-notice"
            e.elements.each { |e1| parse(e1, div) }
          else
            parse(e, div) unless e.name == "title"
          end
        end
      end
    end

    def foreword(isoxml, out)
      f = isoxml.at(ns("//foreword")) || return
      page_break(out)
      out.div **attr_code(id: f["id"]) do |s|
        s.h1 **{ class: "ForewordTitle" } { |h1| h1 << "Foreword" }
        f.elements.each { |e| parse(e, s) unless e.name == "title" }
      end
    end
=end
  end
end
