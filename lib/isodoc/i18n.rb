module IsoDoc
  class Convert

    def i18n_init(lang)
    @lang = lang
      @term_def_boilerplate = 
        case lang
        when "zh" then <<~BOILERPLATE.freeze
      <p>ISO and IEC maintain terminological databases for use in
      standardization at the following addresses:</p>

      <ul> 
      <li> <p>ISO在线浏览平台:
        <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
      <li> <p>IEC Electropedia: 
        <a href="http://www.electropedia.org">http://www.electropedia.org</a>
      </p> </li> </ul>
          BOILERPLATE
        else
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
        end

      @scope_lbl = 
        case lang
        when "zh"
          "范围".freeze
        else
          "Scope".freeze
        end

      @symbols_lbl = 
        case lang
        when "zh"
          "符号、代号和缩略语".freeze
        else
          "Symbols and Abbreviated Terms".freeze
        end

      @introduction_lbl =
        case lang
        when "zh"
          "引言".freeze
        else
          "Introduction".freeze
        end

      @foreword_lbl =
        case lang
        when "zh"
          "前言".freeze
        else
          "Foreword".freeze
        end

      @termsdef_lbl =
        case lang
        when "zh"
          "术语和定义".freeze
        else
          "Terms and Definitions".freeze
        end   

      @termsdefsymbols_lbl =
        case lang
        when "zh"
          "术语、定义、符号、代号和缩略语".freeze
        else
          "Terms, Definitions, Symbols and Abbreviated Terms".freeze
        end
        
    @normref_lbl =
    case lang
    when "zh"
    "规范性引用文件".freeze
    else
    "Normative References".freeze
    end

    @bibliography_lbl =
    case lang
    when "zh"
    "参考文献".freeze
    else
    "Bibliography".freeze
    end

      @no_terms_boilerplate =
        case lang
        when "zh"
          "<p>本文件不提供术语和定义。</p>".freeze
        else
          "<p>No terms and definitions are listed in this document.</p>".freeze
        end

      @internal_terms_boilerplate =
        case lang
        when "zh"
          "<p>下列术语和定义适用于本文件。</p>".freeze
        else
          "<p>For the purposes of this document, "\
            "the following terms and definitions apply.</p>".freeze
        end

@norm_with_refs_pref =
case lang
when "zh"
<<~BOILERPLATE
          下列文件对于本文件的应用是必不可少的。
          凡是注日期的引用文件，仅注日期的版本适用于本文件。
          凡是不注日期的引用文件，其最新版本（包括所有的修改单）适用于本文件。
      BOILERPLATE
      else
<<~BOILERPLATE.freeze
      The following documents are referred to in the text in such a way
      that some or all of their content constitutes requirements of this
      document. For dated references, only the edition cited applies.
      For undated references, the latest edition of the referenced
      document (including any amendments) applies.
    BOILERPLATE
end

@norm_empty_pref =
case lang
when "zh"
 "本文件并没有规范性引用文件。".freeze
else
"There are no normative references in this document.".freeze
end

    end

   def external_terms_boilerplate(sources)
        case @lang
        when "zh"
          "<p>#{sources} 界定的术语和定义适用于本文件。</p>".freeze
        else
          "<p>For the purposes of this document, "\
            "the terms and definitions given in #{sources} apply.</p>".freeze
        end
end

      def internal_external_terms_boilerplate(sources)
        case @lang
        when "zh"
          "<p>#{sources} 界定的以及下列术语和定义适用于本文件。</p>".freeze
        else
          "<p>For the purposes of this document, "\
            "the terms and definitions given in #{sources} "\
            "and the following apply.</p>".freeze
        end
end

  end
end
