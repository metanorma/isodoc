module IsoDoc::WordFunction
  module Body
    def section_break(body)
      body.p do |p|
        p.br **{ clear: "all", class: "section" }
      end
    end

    def page_break(out)
      out.p do |p|
        p.br **{ clear: "all",
                 style: "mso-special-character:line-break;"\
                 "page-break-before:always" }
      end
    end

    def pagebreak_parse(node, out)
      return page_break(out) if node["orientation"].nil?
      out.p do |p|
        p.br **{clear: "all", class: "section",
                orientation: node["orientation"] }
      end
    end

    def imgsrc(node)
      ret = svg_to_emf(node) and return ret
      return node["src"] unless %r{^data:image/}.match node["src"]
      save_dataimage(node["src"])
    end

    def image_parse(node, out, caption)
      attrs = { src: imgsrc(node),
                height: node["height"],
                alt: node["alt"],
                title: node["title"],
                width: node["width"] }
      out.img **attr_code(attrs)
      image_title_parse(out, caption)
    end

    def svg_to_emf_filename(uri)
      File.join(File.dirname(uri), File.basename(uri), ".emf")
    end

    def svg_to_emf(node)
      return unless node["mimetype"] == "image/svg+xml"
      uri = node["src"]
      %r{^data:image/}.match(uri) and uri = save_dataimage(uri)
      ret = svg_to_emf_filename(uri)
      File.exists?(ret) and return ret
      exe = inkspace_installed? or return nil
      system %(inkscape --export-type="emf" #{uri}) and
        return ret
      nil
    end

    def self.inkspace_installed?
      cmd = "inkspace"
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      nil
    end

    def xref_parse(node, out)
      target = /#/.match(node["target"]) ? node["target"].sub(/#/, ".doc#") :
        "##{node["target"]}"
        out.a(**{ "href": target }) { |l| l << get_linkend(node) }
    end
  end
end
