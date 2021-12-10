require "yaml"

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
      when String then ret.unicode_normalize(:nfc)
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
      @labels.each do |k, v|
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
      if lang == "zh" && script == "Hans"
        xml = Nokogiri::HTML::DocumentFragment.parse(text)
        xml.traverse do |n|
          next unless n.text?

          n.replace(n.text.gsub(/ /, "").gsub(/:/, "：").gsub(/,/, "、")
            .gsub(/\(/, "（").gsub(/\)/, "）").gsub(/\[/, "【").gsub(/\]/, "】"))
        end
        xml.to_xml.gsub(/<b>/, "").gsub("</b>", "").gsub(/<\?[^>]+>/, "")
      else text
      end
    end

    def multiple_and(names, andword)
      return "" if names.empty?
      return names[0] if names.length == 1

      (names.length == 2) &&
        (return l10n("#{names[0]} #{andword} #{names[1]}", @lang, @script))
      l10n(names[0..-2].join(", ") + " #{andword} #{names[-1]}", @lang, @script)
    end

    # module_function :l10n
  end
end
