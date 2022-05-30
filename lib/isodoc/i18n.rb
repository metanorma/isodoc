require "yaml"
require "isodoc-i18n"
require_relative "function/utils"

module IsoDoc
  class I18n
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
  end
end

class ::Hash
  def deep_merge(second)
    merger = proc { |_, v1, v2|
      if Hash === v1 && Hash === v2
        v1.merge(v2, &merger)
      elsif Array === v1 && Array === v2
        v1 | v2
      elsif [:undefined, nil,
             :nil].include?(v2)
        v1
      else
        v2
      end
    }
    merge(second.to_h, &merger)
  end
end

