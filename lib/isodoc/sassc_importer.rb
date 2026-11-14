# frozen_string_literal: true

require "sassc-embedded"

# Resolves and reads stylesheet imports on the Ruby side, carrying the
# contents inline in the Import. The sass helper process then never touches
# the filesystem for an import — which is what lets the render run against
# stylesheets that live inside a read-only packaged image (tebako payloads):
# the helper's own filesystem view does not include the image's paths, so a
# path-only Import dies helper-side as "Can't find stylesheet to import"
# (tebako#1056). Reads here go through Ruby's File, which the packaged
# runtime's IO shims answer from the image on every platform.
class SasscImporter < SassC::Importer
  def initialize(options)
    super
    @load_paths = Array(options[:load_paths])
  end

  def imports(path, parent_path)
    unless path.match?(/(css|scss)$/)
      resolved = resolve(path, parent_path)
      return Import.new(resolved, source: File.read(resolved)) if resolved

      # A path Ruby cannot see (a helper-owned or built-in spelling) keeps
      # the historic shape: the name, path-only, resolved by the helper.
      Import.new("#{path}.scss")
    end
  end

  private

  # dart-sass's resolution order for the forms isodoc's stylesheets use:
  # the importing file's own directory first, then the load paths; the
  # partial (_-prefixed) spelling beside the plain one.
  def resolve(path, parent_path)
    dirs = [parent_path && File.dirname(parent_path), *@load_paths].compact.uniq
    dirs.each do |dir|
      [File.join(dir, "_#{path}.scss"), File.join(dir, "#{path}.scss")].each do |candidate|
        return candidate if File.file?(candidate)
      end
    end
    nil
  end
end
