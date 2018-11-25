require "yaml"

# TODO: Cleanup and generalize
module IsoDoc::Function
  module I18n
    def load_yaml(lang, script)
      if @i18nyaml
        YAML.load_file(@i18nyaml)
      elsif lang == "en"
        YAML.load_file(File.join(File.dirname(__FILE__),
                                 "../../isodoc-yaml/i18n-en.yaml"))
      elsif lang == "fr"
        YAML.load_file(File.join(File.dirname(__FILE__),
                                 "../../isodoc-yaml/i18n-fr.yaml"))
      elsif lang == "zh" && script == "Hans"
        YAML.load_file(File.join(File.dirname(__FILE__),
                                 "../../isodoc-yaml/i18n-zh-Hans.yaml"))
      else
        YAML.load_file(File.join(File.dirname(__FILE__),
                                 "../../isodoc-yaml/i18n-en.yaml"))
      end
    end

    def i18n_init(lang, script)
      @lang = lang
      @script = script
      y = load_yaml(lang, script)
      @term_def_boilerplate = y["term_def_boilerplate"]
      @scope_lbl = y["scope"]
      @symbols_lbl = y["symbols"]
      @table_of_contents_lbl = y["table_of_contents"]
      @introduction_lbl = y["introduction"]
      @foreword_lbl = y["foreword"]
      @abstract_lbl = y["abstract"]
      @termsdef_lbl = y["termsdef"]
      @termsdefsymbols_lbl = y["termsdefsymbols"]
      @normref_lbl = y["normref"]
      @bibliography_lbl = y["bibliography"]
      @clause_lbl = y["clause"]
      @annex_lbl = y["annex"]
      @appendix_lbl = y["appendix"]
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
      @list_lbl = y["list"]
      @formula_lbl = y["formula"]
      @table_lbl = y["table"]
      @key_lbl = y["key"]
      @example_lbl = y["example"]
      @example_xref_lbl = y["example_xref"]
      @where_lbl = y["where"]
      @wholeoftext_lbl = y["wholeoftext"]
      @draft_lbl = y["draft_label"]
      @inform_annex_lbl = y["inform_annex"]
      @norm_annex_lbl = y["norm_annex"]
      @modified_lbl = y["modified"]
      @deprecated_lbl = y["deprecated"]
      @source_lbl = y["source"]
      @and_lbl = y["and"]
      @all_parts_lbl = y["all_parts"]
      @locality = y["locality"]
      @admonition = y["admonition"]
      @labels = y
      @labels["language"] = @lang
      @labels["script"] = @script
    end

    # TODO: move to localization file
    def eref_localities1_zh(target, type, from, to)
      ret = ", 第#{from.text}" if from
      ret += "&ndash;#{to}" if to
      loc = (@locality[type] || type.sub(/^locality:/, "").capitalize )
      ret += " #{loc}"
      ret
    end

    # TODO: move to localization file
    def eref_localities1(target, type, from, to, lang = "en")
      return l10n(eref_localities1_zh(target, type, from, to)) if lang == "zh"
      ret = ","
      loc = @locality[type] || type.sub(/^locality:/, "").capitalize
      ret += " #{loc}"
      ret += " #{from.text}" if from
      ret += "&ndash;#{to.text}" if to
      l10n(ret)
    end

    # TODO: move to localization file
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

    module_function :l10n

  end
end
