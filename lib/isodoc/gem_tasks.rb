# frozen_string_literal: true

require "sassc-embedded"
require "isodoc/sassc_importer"
require "rake/clean"
require "tmpdir"

module IsoDoc
  module GemTasks
    extend Rake::DSL if defined? Rake::DSL

    @@css_list = []

    module_function

    def self.css_list
      @@css_list
    end

    def install
      rule ".css" => [proc { |tn| tn.sub(/\.css$/, ".scss") }] do |current_task|
        puts(current_task)
        compile_scss_task(current_task)
      rescue StandardError => e
        notify_broken_compilation(e, current_task)
      end

      scss_files = Rake::FileList["lib/**/*.scss"]
      source_files = scss_files.ext(".css")

      task :comment_out_liquid do
        process_css_files(scss_files) do |file_name|
          comment_out_liquid(File.read(file_name, encoding: "UTF-8"))
        end
      end

      task build_scss: [:comment_out_liquid].push(*source_files) do
        process_css_files(scss_files) do |file_name|
          uncomment_out_liquid(File.read(file_name, encoding: "UTF-8"))
        end
        git_cache_compiled_files && puts("Built scss!")
      end

      Rake::Task["build"].enhance [:build_scss] do
        git_rm_compiled_files
        Rake::Task[:clean].invoke
      end
    end

    def interactive?
      ENV["CI"] == nil
    end

    def notify_broken_compilation(error, current_task)
      puts("Cannot compile #{current_task} because of #{error.message}")
      return unless interactive?

      puts("continue anyway[y|n]?")
      answer = $stdin.gets.strip
      exit(0) unless %w[y yes].include?(answer.strip.downcase)
    end

    def git_cache_compiled_files
      @@css_list.each do |css_file|
        sh "git add #{css_file}"
      end
    end

    def git_rm_compiled_files
      @@css_list.each do |css_file|
        sh "git rm --cached #{css_file}"
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
        if line.match?(/(?<!{){({|%)(?![{%]).+(}|%)}/)
          "/* LIQUID_COMMENT#{line}LIQUID_COMMENT */"
        else
          line
        end
      end.join("\n")
    end

    def uncomment_out_liquid(text)
      text
        .gsub("/* LIQUID_COMMENT", "")
        .gsub("LIQUID_COMMENT */", "")
        .gsub('"{{', "{{").gsub('}}"', "}}")
    end

    def fonts_placeholder
      <<~TEXT
        $bodyfont: "{{bodyfont}}";
        $headerfont: "{{headerfont}}";
        $monospacefont: "{{monospacefont}}";
        $normalfontsize: "{{normalfontsize}}";
        $smallerfontsize: "{{smallerfontsize}}";
        $footnotefontsize: "{{footnotefontsize}}";
        $monospacefontsize: "{{monospacefontsize}}";
      TEXT
    end

    def compile_scss(filename)
      load_scss_paths(filename)
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "variables.scss"), fonts_placeholder)
        SassC.load_paths << dir
        sheet_content = File.read(filename, encoding: "UTF-8")
          .gsub(%r<([a-z])\.([0-9])(?=[^{}]*{)>m, "\\1.__WORD__\\2")
        SassC::Engine.new(%<@use "variables" as *;\n#{sheet_content}>,
                          syntax: :scss, importer: SasscImporter)
          .render.gsub(/__WORD__/, "")
      end
    end

    def load_scss_paths(filename)
      require "sassc-embedded"
      require "isodoc/sassc_importer"
      isodoc_path = if Gem.loaded_specs["isodoc"]
                      File.join(Gem.loaded_specs["isodoc"].full_gem_path,
                                "lib", "isodoc")
                    else File.join("lib", "isodoc")
                    end
      [isodoc_path,
       File.dirname(filename)].each do |name|
         SassC.load_paths << name
       end
    end

    def compile_scss_task(current_task)
      filename = current_task.source
      basename = File.basename(filename, ".*")
      compiled_path = File.join(File.dirname(filename), "#{basename}.css")
      content = uncomment_out_liquid(compile_scss(filename))
      File.open(compiled_path, "w:UTF-8") do |f|
        f.write(content)
      end
      @@css_list << compiled_path
      CLEAN << compiled_path
    end
  end
end
