require 'sassc'
require 'isodoc/sassc_importer'
require 'rake/clean'

module IsoDoc
  module GemTasks
    extend Rake::DSL if defined? Rake::DSL

    module_function

    def install
      rule '.css' => [proc { |tn| tn.sub(/\.css$/, '.scss') }] do |current_task|
        compile_scss(current_task)
      end

      scss_files = Rake::FileList["lib/**/*.scss"]
      source_files = scss_files.ext('.css')

      task :comment_out_liquid do
        process_css_files(scss_files) do |file_name|
          comment_out_liquid(File.read(file_name, encoding: "UTF-8"))
        end
      end

      task :build_scss => [:comment_out_liquid].push(*source_files) do
        process_css_files(scss_files) do |file_name|
          uncomment_out_liquid(File.read(file_name, encoding: "UTF-8"))
        end
        puts('Built scss!')
      end

      Rake::Task["build"].enhance [:build_scss] do
        # Rake::Task[:clean].invoke
      end
    end

    def process_css_files(scss_files)
      scss_files.each do |file_name|
        result = yield(file_name)
        File.open(file_name, "w", encoding: "UTF-8") do |file|
          file.puts(result)
        end
      end
    end

    def comment_out_liquid(text)
      text.split("\n").map do |line|
        if line =~ /{({|%).+(}|%)}/
          "/* LIQUID_COMMENT#{line}LIQUID_COMMENT */"
        else
          line
        end
      end
      .join("\n")
    end

    def uncomment_out_liquid(text)
      text
        .gsub('/* LIQUID_COMMENT', '')
        .gsub('LIQUID_COMMENT */', '')
        .gsub('"{{', '{{').gsub('}}"', '}}')
    end

    def compile_scss(current_task)
      puts(current_task)
      filename = current_task.source
      require "sassc"
      SassC.load_paths << File.join(Gem.loaded_specs['isodoc'].full_gem_path, "lib", "isodoc")
      SassC.load_paths << File.dirname(filename)
      fonts_placeholder = "$bodyfont: '{{bodyfont}}';\n$headerfont: '{{headerfont}}';\n$monospacefont: '{{monospacefont}}';\n"
      sheet_content = File.read(filename, encoding: "UTF-8")
      engine = SassC::Engine.new(fonts_placeholder + sheet_content, syntax: :scss, importer: SasscImporter)
      basename = File.basename(filename, '.*')
      compiled_path = File.join(File.dirname(filename), "#{basename}.css")
      begin
        content = uncomment_out_liquid(engine.render)
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
