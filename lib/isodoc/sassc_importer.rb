# frozen_string_literal: true

require "sassc-embedded"

class SasscImporter < SassC::Importer
  def imports(path, _parent_path)
    unless path.match?(/(css|scss)$/)
      Import.new("#{path}.scss")
    end
  end
end
