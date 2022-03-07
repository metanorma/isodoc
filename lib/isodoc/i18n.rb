require "yaml"
require_relative "function/utils"

module IsoDoc
  class I18n
    def load_yaml(lang, script, i18nyaml = nil)
      ret = load_yaml1(lang, script)
      return normalise_hash(ret.merge(YAML.load_file(i18nyaml))) if i18nyaml

      normalise_hash(ret)
    end

    def normalise_hash(ret)
      case ret
      when Hash
        ret.each do |k, v|
          ret[k] = normalise_hash(v)
        end
        ret
      when Array then ret.map { |n| normalise_hash(n) }
      when String then cleanup_entities(ret.unicode_normalize(:nfc))
      else ret
      end
    end

    def load_yaml1(lang, script)
      case lang
      when "en", "fr", "ru", "de", "es", "ar"
        load_yaml2(lang)
      when "zh"
        if script == "Hans" then load_yaml2("zh-Hans")
        else load_yaml2("en")
        end
      else
        load_yaml2("en")
      end
    end

    def load_yaml2(str)
      YAML.load_file(File.join(File.dirname(__FILE__),
                               "../isodoc-yaml/i18n-#{str}.yaml"))
    end

    def get
      @labels
    end

    def set(key, val)
      @labels[key] = val
    end

    def initialize(lang, script, i18nyaml = nil)
      @lang = lang
      @script = script
      y = load_yaml(lang, script, i18nyaml)
      @labels = y
      @labels["language"] = @lang
      @labels["script"] = @script
      @labels.each do |k, _v|
        self.class.send(:define_method, k.downcase) { get[k] }
      end
    end

    def self.l10n(text, lang = @lang, script = @script)
      l10n(text, lang, script)
    end

    # TODO: move to localization file
    # function localising spaces and punctuation.
    # Not clear if period needs to be localised for zh
    def l10n(text, lang = @lang, script = @script)
      if lang == "zh" && script == "Hans" then l10n_zh(text)
      else bidiwrap(text, lang, script)
      end
    end

    def bidiwrap(text, lang, script)
      my_script, my_rtl, outer_rtl = bidiwrap_vars(lang, script)
      if my_rtl && !outer_rtl
        mark = %w(Arab Aran).include?(my_script) ? "&#x61c;" : "&#x200f;"
        "#{mark}#{text}#{mark}"
      elsif !my_rtl && outer_rtl then "&#x200e;#{text}&#x200e;"
      else text
      end
    end

    def bidiwrap_vars(lang, script)
      my_script = script || Metanorma::Utils.default_script(lang)
      [my_script,
       Metanorma::Utils.rtl_script?(my_script),
       Metanorma::Utils.rtl_script?(@script || Metanorma::Utils
         .default_script(@lang))]
    end

    def l10n_zh(text)
      xml = Nokogiri::HTML::DocumentFragment.parse(text)
      xml.traverse do |n|
        next unless n.text?

        n.replace(cleanup_entities(n.text.gsub(/ /, "").gsub(/:/, "：")
          .gsub(/,/, "、").gsub(/\(/, "（").gsub(/\)/, "）")
          .gsub(/\[/, "【").gsub(/\]/, "】"), is_xml: false))
      end
      xml.to_xml.gsub(/<b>/, "").gsub("</b>", "").gsub(/<\?[^>]+>/, "")
    end

    def boolean_conj(list, conn)
      case list.size
      when 0 then ""
      when 1 then list.first
      when 2 then @labels["binary_#{conn}"].sub(/%1/, list[0])
        .sub(/%2/, list[1])
      else
        @labels["multiple_#{conn}"]
          .sub(/%1/, l10n(list[0..-2].join(", "), @lang, @script))
          .sub(/%2/, list[-1])
      end
    end

    #     def multiple_and(names, andword)
    #       return "" if names.empty?
    #       return names[0] if names.length == 1
    #
    #       (names.length == 2) &&
    #         (return l10n("#{names[0]} #{andword} #{names[1]}", @lang, @script))
    #       l10n(names[0..-2].join(", ") + " #{andword} #{names[-1]}", @lang, @script)
    #     end

    include Function::Utils
    # module_function :l10n
  end
end
