module IsoDoc
  class Convert < ::IsoDoc::Common
    # Check if already compiled version(.css) exists,
    #   if not, return original scss file. During release
    #   we compile scss into css files in order to not depend on scss
    def precompiled_style_or_original(stylesheet_path)
      # Already have compiled stylesheet, use it
      return stylesheet_path if stylesheet_path.nil? ||
        File.extname(stylesheet_path) == '.css'
      basename = File.basename(stylesheet_path, '.*')
      compiled_path = File.join(File.dirname(stylesheet_path),
                                "#{basename}.css")
      return stylesheet_path unless File.file?(compiled_path)
      compiled_path
    end

    # run this after @meta is populated
    def populate_css
      @htmlstylesheet = generate_css(@htmlstylesheet_name, true)
      @wordstylesheet = generate_css(@wordstylesheet_name, false)
      @standardstylesheet = generate_css(@standardstylesheet_name, false)
    end

    def default_fonts(_options)
      {
        bodyfont: 'Arial',
        headerfont: 'Arial',
        monospacefont: 'Courier',
      }
    end

    # none for this parent gem, but will be populated in child gems
    # which have access to stylesheets &c
    def default_file_locations(_options)
      {}
    end

    def fonts_options
      {
        'bodyfont' => options[:bodyfont] || 'Arial',
        'headerfont' => options[:headerfont] || 'Arial',
        'monospacefont' => options[:monospacefont] || 'Courier',
        "normalfontsize" => options[:normalfontsize],
        "monospacefontsize" => options[:monospacefontsize],
        "smallerfontsize" => options[:smallerfontsize],
        "footnotefontsize" => options[:footnotefontsize] 
      }
    end

    def scss_fontheader(is_html_css)
      b = options[:bodyfont] || 'Arial'
      h = options[:headerfont] || 'Arial'
      m = options[:monospacefont] || 'Courier'
      ns = options[:normalfontsize] || (is_html_css ? "1.0em" : '12.0pt')
      ms = options[:monospacefontsize] || (is_html_css ? "0.8em" : '11.0pt')
      ss = options[:smallerfontsize] || (is_html_css ? "0.9em" : '10.0pt')
      fs = options[:footnotefontsize] || (is_html_css ? "0.9em" : '9.0pt')
      "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"\
        "$normalfontsize: #{ns};\n$monospacefontsize: #{ms};\n"\
        "$smallerfontsize: #{ss};\n$footnotefontsize: #{fs};\n"
    end

    def convert_scss(filename, stylesheet, stripwordcss)
      require 'sassc'
      require 'isodoc/sassc_importer'

      [File.join(Gem.loaded_specs['isodoc'].full_gem_path,
                 'lib', 'isodoc'),
                 File.dirname(filename)].each do |name|
                   SassC.load_paths << name
                 end
                 SassC::Engine.new(scss_fontheader(stripwordcss) + stylesheet,
                                   syntax: :scss, importer: SasscImporter)
                   .render
    end

    # stripwordcss if HTML stylesheet, !stripwordcss if DOC stylesheet
    def generate_css(filename, stripwordcss)
      return nil if filename.nil?

      filename = precompiled_style_or_original(filename)
      stylesheet = File.read(filename, encoding: 'UTF-8')
      stylesheet = populate_template(stylesheet, :word)
      stylesheet.gsub!(/(\s|\{)mso-[^:]+:[^;]+;/m, '\\1') if stripwordcss
      if File.extname(filename) == '.scss'
        stylesheet = convert_scss(filename, stylesheet, stripwordcss)
      end
      Tempfile.open([File.basename(filename, '.*'), 'css'],
                    encoding: 'utf-8') do |f|
        f.write(stylesheet)
        f
      end
    end
  end
end
