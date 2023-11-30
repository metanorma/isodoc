require "yaml"
require "isodoc-i18n"
require_relative "function/utils"
require "metanorma-utils"

module IsoDoc
  class I18n
    Hash.include Metanorma::Utils::Hash

    def yaml_lang(lang, script)
      case lang
      when "en", "fr", "ru", "de", "es", "ar", "ja"
        lang
      when "zh"
        "#{lang}-#{script}"
      end
    end

    def load_yaml1(lang, script)
      load_yaml2(yaml_lang(lang, script))
    end

    def load_yaml2(str)
      f = File.join(File.dirname(__FILE__),
                    "../isodoc-yaml/i18n-#{str}.yaml")
      File.exist?(f) or
        f = File.join(File.dirname(__FILE__),
                      "../isodoc-yaml/i18n-en.yaml")
      YAML.load_file(f)
    end
  end
end
