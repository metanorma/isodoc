# frozen_string_literal: true

require 'sassc'
require 'isodoc/sassc_importer'
require 'rake/clean'

module IsoDoc
  module GemTasks
    extend Rake::DSL if defined? Rake::DSL

    module_function

    def install
      rule '.css' => [proc { |tn| tn.sub(/\.css$/, '.scss') }] do |current_task|
        begin
          puts(current_task)
          compile_scss_task(current_task)
        rescue StandardError => e
          puts(e.message, "skiping #{current_task}")
        end
      end

      scss_files = Rake::FileList['lib/**/*.scss']
      source_files = scss_files.ext('.css')

      task :comment_out_liquid do
        process_css_files(scss_files) do |file_name|
          comment_out_liquid(File.read(file_name, encoding: 'UTF-8'))
        end
      end

      task build_scss: [:comment_out_liquid].push(*source_files) do
        process_css_files(scss_files) do |file_name|
          uncomment_out_liquid(File.read(file_name, encoding: 'UTF-8'))
        end
        git_cache_compiled_files && puts('Built scss!')
      end

      Rake::Task['build'].enhance [:build_scss] do
        git_rm_compiled_files
        Rake::Task[:clean].invoke
      end
    end

    def git_cache_compiled_files
      CLEAN.each do |css_file|
        sh "git add #{css_file}"
      end
    end

    def git_rm_compiled_files
      CLEAN.each do |css_file|
        sh "git rm --cached #{css_file}"
      end
    end

    def process_css_files(scss_files)
      scss_files.each do |file_name|
        result = yield(file_name)
        File.open(file_name, 'w', encoding: 'UTF-8') do |file|
          file.puts(result)
        end
      end
    end

    def comment_out_liquid(text)
      text.split("\n").map do |line|
        if line.match?(/{({|%).+(}|%)}/)
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

    def fonts_placeholder
      <<~TEXT
        $bodyfont: '{{bodyfont}}';
        $headerfont: '{{headerfont}}';
        $monospacefont: '{{monospacefont}}';
      TEXT
    end

    def compile_scss(filename)
      require 'sassc'

      [File.join('lib', 'isodoc'),
       File.dirname(filename)].each do |name|
        SassC.load_paths << name
      end
      sheet_content = File.read(filename, encoding: 'UTF-8')
      SassC::Engine.new(fonts_placeholder + sheet_content,
                        syntax: :scss,
                        importer: SasscImporter)
                   .render
    end

    def compile_scss_task(current_task)
      filename = current_task.source
      basename = File.basename(filename, '.*')
      compiled_path = File.join(File.dirname(filename), "#{basename}.css")
      content = uncomment_out_liquid(compile_scss(filename))
      File.open(compiled_path, 'w:UTF-8') do |f|
        f.write(content)
      end
      CLEAN << compiled_path
    end
  end
end
