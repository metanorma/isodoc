require "relaton-render"
require "metanorma-utils"

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
