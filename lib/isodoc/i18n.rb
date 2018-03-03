require "yaml"

module IsoDoc
  class Convert

    def i18n_init(lang, script)
      @lang = lang
      @script = script

      @term_def_boilerplate = case lang
      # TODO
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
                              when "fr" then <<~BOILERPLATE.freeze
      <p>L'ISO et l'IEC tiennent à jour des bases de données terminologiques
      destinées à être utilisées en normalisation, consultables aux adresses
      suivantes:</p>
      <ul>
      <li> <p>ISO Online browsing platform: disponible à l'adresse
        <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
      <li> <p>IEC Electropedia: disponible à l'adresse
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

      @scope_lbl = case lang
                   when "zh" then "范围".freeze
                   when "fr" then "Domaine d'application".freeze
                   else
                     "Scope".freeze
                   end

      @symbols_lbl = case lang
                     when "zh"
                       "符号、代号和缩略语".freeze
                     when "fr"
                       "Symboles et termes abrégés".freeze
                     else
                       "Symbols and Abbreviated Terms".freeze
                     end

      @introduction_lbl = case lang
                          when "zh" then "引言".freeze
                          when "fr"
                            "Introduction".freeze
                          else
                            "Introduction".freeze
                          end

      @foreword_lbl = case lang
                      when "zh" then "前言".freeze
                      when "fr" then "Avant-propos".freeze
                      else
                        "Foreword".freeze
                      end

      @termsdef_lbl = case lang
                      when "zh" then "术语和定义".freeze
                      when "fr" then "Terms et définitions".freeze
                      else
                        "Terms and Definitions".freeze
                      end  

      @termsdefsymbols_lbl =
        case lang
        when "zh"
          "术语、定义、符号、代号和缩略语".freeze
        when "fr"
          "Terms, définitions, symboles et termes abrégés".freeze
        else
          "Terms, Definitions, Symbols and Abbreviated Terms".freeze
        end

      @normref_lbl = case lang
                     when "zh" then "规范性引用文件".freeze
                     when "fr" then "Références normatives".freeze
                     else
                       "Normative References".freeze
                     end

      @bibliography_lbl = case lang
                          when "zh" then "参考文献".freeze
                          when "fr" then "Bibliographie".freeze
                          else
                            "Bibliography".freeze
                          end

      @clause_lbl = case lang
                    when "zh" then "条".freeze
                    when "fr" then "Article".freeze
                    else
                      "Clause".freeze
                    end

      @annex_lbl = case lang
                   when "zh" then "附录".freeze
                   when "fr" then "Annexe".freeze
                   else
                     "Annex".freeze
                   end

      @no_terms_boilerplate =
        case lang
        when "zh"
          "<p>本文件不提供术语和定义。</p>".freeze
        when "fr"
          "<p>Aucun terme n'est defini dans le présent document.</p>".freeze
        else
          "<p>No terms and definitions are listed in this document.</p>".freeze
        end

      @internal_terms_boilerplate =
        case lang
        when "zh"
          "<p>下列术语和定义适用于本文件。</p>".freeze
        when "fr"
          "<p>Pour les besoins du présent document, les termes et définitions suivants s'appliquent.</p>".freeze
        else
          "<p>For the purposes of this document, "\
            "the following terms and definitions apply.</p>".freeze
        end

      @norm_with_refs_pref = case lang
                             when "zh"
                               <<~BOILERPLATE
          下列文件对于本文件的应用是必不可少的。
          凡是注日期的引用文件，仅注日期的版本适用于本文件。
          凡是不注日期的引用文件，其最新版本（包括所有的修改单）适用于本文件。
                               BOILERPLATE
                             when "fr"
                               <<~BOILERPLATE.freeze
     Les documents suivants cités dans le texte constituent, pour tout ou partie de leur contenu, des exigences du présent document. Pour les références datées, seule l’édition citée s'applique. Pour les références non datées, la dernière édition du document de référence s'applique (y compris les éventuels amendements).
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
        when "fr"
          "Le présent document ne contient aucune référence normative.".freeze
        else
          "There are no normative references in this document.".freeze
        end

      @external_terms_boilerplate =
        case lang
        when "zh"
          "<p>% 界定的术语和定义适用于本文件。</p>".freeze
        when "fr"
          "<p>Pour les besoins du présent document, les termes et définitions de % s'appliquent.</p>".freeze
        else
          "<p>For the purposes of this document, "\
            "the terms and definitions given in % apply.</p>".freeze
        end

      @internal_external_terms_boilerplate =
        case lang
        when "zh"
          "<p>% 界定的以及下列术语和定义适用于本文件。</p>".freeze
        when "fr"
          "<p>Pour les besoins du présent document, les termes et définitions de % ainsi que les suivants, s'appliquent.</p>".freeze
        else
          "<p>For the purposes of this document, the terms and definitions "\
            "given in % and the following apply.</p>".freeze
        end

      @note_lbl = case lang
                  when "zh" then "注".freeze
                  when "fr" then "NOTE".freeze
                  else
                    "NOTE".freeze
                  end

      @note_xref_lbl = case lang
                       when "zh" then "注".freeze
                       when "fr" then "Note".freeze
                       else
                         "Note".freeze
                       end

      @termnote_lbl = case lang
                        when "zh" then "注%".freeze
                        when "fr" then "Note % à l'article".freeze
                        else
                          "Note % to entry".freeze
                        end

      @figure_lbl = case lang
                    when "zh" then "图".freeze
                    when "fr" then "Figure".freeze
                    else
                      "Figure".freeze
                    end

      @formula_lbl = case lang
                     when "zh" then "公式".freeze
                     when "fr" then "Formule".freeze
                     else
                       "Formula".freeze
                     end

      @table_lbl = case lang
                   when "zh" then "表".freeze
                   when "fr" then "Tableau".freeze
                   else
                     "Table".freeze
                   end

      @key_lbl = case lang
                 when "zh" then "说明".freeze
                 when "fr" then "Légende".freeze
                 else
                   "Key".freeze
                 end

      @example_lbl = case lang
                     when "zh" then "示例".freeze
                     when "fr" then "EXEMPLE".freeze
                     else
                       "EXAMPLE".freeze
                     end

      @example_xref_lbl = case lang
                          when "zh" then "示例".freeze
                          when "fr" then "Exemple".freeze
                          else
                            "Example".freeze
                          end

      @where_lbl = case lang
                   when "zh" then "式中".freeze
                   when "fr" then "où".freeze
                   else
                     "where".freeze
                   end

      @wholeoftext_lbl = case lang
                         when "zh" then "全部".freeze
                         when "fr" then "Ensemble du texte".freeze
                         else
                           "Whole of text".freeze
                         end

      @draft_lbl = case lang
                   when "zh" then "稿".freeze
                   when "fr" then "brouillon".freeze
                   else
                     "draft".freeze
                   end

      @inform_annex_lbl = case lang
                          when "zh" then "资料性附录".freeze
                          when "fr" then "informative".freeze
                          else
                            "informative".freeze
                          end

      @norm_annex_lbl = case lang
                        when "zh" then "规范性附录".freeze
                        when "fr" then "normative".freeze
                        else
                          "normative".freeze
                        end

      @modified_lbl = case lang
                      when "zh" then "改写".freeze
                      when "fr" then "modifié".freeze
                      else
                        "modified".freeze
                      end

      @deprecated_lbl = case lang
                        when "zh" then "被取代".freeze
                        when "fr" then "DÉCONSEILLÉ".freeze
                        else
                          "DEPRECATED".freeze
                        end

      @source_lbl = case lang
                    when "zh" then "定义".freeze
                    when "fr" then "SOURCE".freeze
                    else
                      "SOURCE".freeze
                    end

      @and_lbl = case lang
                 when "zh" then "和".freeze
                 when "fr" then "et".freeze
                 else
                   "and".freeze
                 end

      @all_parts_lbl = case lang
# TODO
                 when "zh" then "All Parts".freeze
                 when "fr" then "toutes les parties".freeze
                 else
                   "All Parts".freeze
                 end

      @locality = case lang
                  when "zh"
                    {
                      section: "条",
                      clause: "条",
                      part: "部分",
                      paragraph: "段",
                      chapter: "章",
                      page: "页",
                      table: "表",
                      annex: "附录",
                      figure: "图",
                      example: "示例",
                      note: "注",
                      formula: "公式",
                    }.freeze
                when "fr"
                    {
                      section: "Section",
                      clause: "Article",
                      part: "Partie",
                      paragraph: "Alinéa",
                      chapter: "Chapitre",
                      page: "Page",
                      table: "Tableau",
                      annex: "Annexe",
                      figure: "Figure",
                      example: "Exemple",
                      note: "Note",
                      formula: "Formule",
                    }.freeze
                  else
                    {
                      section: "Section",
                      clause: "Clause",
                      part: "Part",
                      paragraph: "Paragraph",
                      chapter: "Chapter",
                      page: "Page",
                      table: "Table",
                      annex: "Annex",
                      figure: "Figure",
                      example: "Example",
                      note: "Note",
                      formula: "Formula",
                    }.freeze
                  end

      if @i18nyaml
        y = YAML.load_file(@i18nyaml)
        @term_def_boilerplate = y["term_def_boilerplate"]
        @scope_lbl = y["scope"]
        @symbols_lbl = y["symbols"]
        @introduction_lbl = y["introduction"]
        @foreword_lbl = y["foreword"]
        @termsdef_lbl = y["termsdef"]
        @termsdefsymbols_lbl = y["termsdefsymbols"]
        @normref_lbl = y["normref"]
        @bibiliography_lbl = y["bibliography"]
        @clause_lbl = y["clause"]
        @annex_lbl = y["annex"]
        @no_terms_boilerplate = y["no_terms_boilerplate"]
        @internal_terms_boilerplate = y["internal_terms_boilerplate"]
        @norm_with_refs_pref = y["norm_with_refs_pref"]
        @norm_empty_pref = y["norm_empty_pref"]
        @external_terms_boilerplate = y["external_terms_boilerplate"]
        @internal_external_terms_boilerplate =
          y["internal_external_terms_boilerplate"]
        @note_lbl = y["note"]
        @note_xref_lbl = y["note_xref"]
        @termnote_lbl = y["termnote"]
        @figure_lbl = y["figure"]
        @formula_lbl = y["formula"]
        @table_lbl = y["table"]
        @key_lbl = y["key"]
        @example_lbl = y["example"]
        @example_xref_lbl = y["example_xref"]
        @where_lbl = y["where"]
        @wholeoftext_lbl = y["wholeoftext"]
        @draft_lbl = y["draft"]
        @inform_annex_lbl = y["inform_annex"]
        @norm_annex_lbl = y["norm_annex"]
        @modified_lbl = y["modified"]
        @deprecated_lbl = y["deprecated"]
        @source_lbl = y["source"]
        @and_lbl = y["and"]
        @all_parts_lbl = y["all_parts"]
        @locality = y["locality"]
      end
    end

    def eref_localities1(type, from, to, lang = "en")
      subsection = from && from.text.match?(/\./)
      if lang == "zh"
        ret = ", 第#{from.text}" if from
        ret += "&ndash;#{to}" if to
        ret += @locality[type.to_sym]
      else
        ret = ","
        ret += @locality[type.to_sym] if subsection && type == "clause"
        ret += " #{from.text}" if from
        ret += "&ndash;#{to.text}" if to
      end
      l10n(ret)
    end

    # function localising spaces and punctuation.
    # Not clear if period needs to be localised for zh
    def l10n(x, lang = @lang, script = @script)
      if lang == "zh" && script == "Hans"
        x.gsub(/ /, "").gsub(/:/, "：").gsub(/,/, "、").
          gsub(/\(/, "（").gsub(/\)/, "）").
          gsub(/\[/, "【").gsub(/\]/, "】").
          gsub(/<b>/, "").gsub("</b>", "")
      else
        x
      end
    end
  end
end
