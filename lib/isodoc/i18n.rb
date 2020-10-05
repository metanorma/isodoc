require "yaml"

module IsoDoc
  class I18n
    def load_yaml(lang, script, i18nyaml = nil)
      ret = load_yaml1(lang, script)
      return ret.merge(YAML.load_file(i18nyaml)) if i18nyaml
      ret
    end

    def load_yaml1(lang, script)
      if lang == "en"
        YAML.load_file(File.join(File.dirname(__FILE__),
                                 "../isodoc-yaml/i18n-en.yaml"))
      elsif lang == "fr"
        YAML.load_file(File.join(File.dirname(__FILE__),
                                 "../isodoc-yaml/i18n-fr.yaml"))
      elsif lang == "zh" && script == "Hans"
        YAML.load_file(File.join(File.dirname(__FILE__),
                                 "../isodoc-yaml/i18n-zh-Hans.yaml"))
      else
        YAML.load_file(File.join(File.dirname(__FILE__),
                                 "../isodoc-yaml/i18n-en.yaml"))
      end
    end

    def get
      @labels
    end

    def set(x, y)
      @labels[x] = y
    end

    def initialize(lang, script, i18nyaml = nil)
      @lang = lang
      @script = script
      y = load_yaml(lang, script, i18nyaml)
      @labels = y
      @labels["language"] = @lang
      @labels["script"] = @script
      @labels.each do |k, v|
        self.class.send(:define_method, k.downcase) { v }
      end
    end

    def self.l10n(x, lang = @lang, script = @script)
      l10n(x, lang, script)
    end

    # TODO: move to localization file
    # function localising spaces and punctuation.
    # Not clear if period needs to be localised for zh
    def l10n(x, lang = @lang, script = @script)
      if lang == "zh" && script == "Hans"
        xml = Nokogiri::HTML::DocumentFragment.parse(x)
        xml.traverse do |n|
          next unless n.text?
          n.replace(n.text.gsub(/ /, "").gsub(/:/, "：").gsub(/,/, "、").
                    gsub(/\(/, "（").gsub(/\)/, "）").
                    gsub(/\[/, "【").gsub(/\]/, "】"))
        end
        xml.to_xml.gsub(/<b>/, "").gsub("</b>", "").gsub(/<\?[^>]+>/, "")
      else
        x
      end
    end

    def multiple_and(names, andword)
      return '' if names.empty?
      return names[0] if names.length == 1
      (names.length == 2) &&
        (return l10n("#{names[0]} #{andword} #{names[1]}", @lang, @script))
      l10n(names[0..-2].join(', ') + " #{andword} #{names[-1]}", @lang, @script)
    end

    #module_function :l10n

  end
end
