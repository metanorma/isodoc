require 'sassc'

class SasscImporter < SassC::Importer
  def imports(path, parent_path)
    unless path =~ /(css|scss)$/
      Import.new("#{path}.scss")
    end
  end
end