require "sassc"
require 'rake/clean'

module IsoDoc
  module GemTasks
    extend Rake::DSL if defined? Rake::DSL

    module_function

    def install
      rule '.css' => [proc { |tn| tn.sub(/\.css$/, '.scss') }] do |current_task|
        compile_scss(current_task)
      end

      source_files = Rake::FileList["lib/**/*.scss"].ext('.css')

      task :build_scss => source_files do
        puts('Built scss!')
      end

      Rake::Task["build"].enhance [:build_scss] do
        # Rake::Task[:clean].invoke
      end
    end

    def comment_out_liquid(text)
      text.split("\n").map do |line|
        if line =~ /{({|%).+(}|%)}/
          "// LIQUID_COMMENT#{line}"
        else
          line
        end
      end
      .join("\n")
    end

    def uncomment_out_liquid(text)
      text.split("\n").map do |line|
        if line =~ /\/\/ LIQUID_COMMENT/
          line.gsub('// LIQUID_COMMENT', '')
        else
          line
        end
      end
      .join("\n")
    end

    def compile_scss(current_task)
      puts(current_task)
      filename = current_task.source
      require "sassc"
      SassC.load_paths << File.join(Gem.loaded_specs['isodoc'].full_gem_path, "lib", "isodoc")
      SassC.load_paths << File.dirname(filename)
      engine = SassC::Engine.new(File.read(filename, encoding: "UTF-8"), syntax: :scss)
      basename = File.basename(filename, '.*')
      compiled_path = File.join(File.dirname(filename), "#{basename}.css")
      begin
        content = engine.render
        File.open(compiled_path, 'w:UTF-8') do |f|
          f.write(content)
        end
        CLEAN << compiled_path
      rescue => e
        puts(e.message)
        puts("skiping #{compiled_path}")
      end
    end
  end
end
