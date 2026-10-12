require "relaton-render"
require "metanorma-utils"

module Relaton
  module Render
    module IsoDoc
      class General < ::Relaton::Render::General
        STYLE_PATH = File.join(__dir__, "styles/isodoc.yml")

        def initialize(options = {})
          options[:style] ||= STYLE_PATH
          super
        end
      end
    end
  end
end
