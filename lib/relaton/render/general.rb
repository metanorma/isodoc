require "relaton-render"

module Relaton
  module Render
    module IsoDoc
      class General < ::Relaton::Render::General
        def config_loc
          YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
        end

        def read_config
          super.deep_merge(config_loc)
        end
      end
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
