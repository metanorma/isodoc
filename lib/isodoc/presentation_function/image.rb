require "base64"
require "emf2svg"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def figure(docxml)
      docxml.xpath(ns("//image")).each { |f| svg_extract(f) }
      docxml.xpath(ns("//figure")).each { |f| figure1(f) }
      docxml.xpath(ns("//svgmap")).each do |s|
        if f = s.at(ns("./figure")) then s.replace(f)
        else s.remove
        end
      end
      docxml.xpath(ns("//image")).each { |f| svg_emf_double(f) }
    end

    def svg_extract(elem)
      return unless %r{^data:image/svg\+xml;}.match?(elem["src"])

      svg = Base64.strict_decode64(elem["src"]
        .sub(%r{^data:image/svg\+xml;(charset=[^;]+;)?base64,}, ""))
      x = Nokogiri::XML.fragment(svg.sub(/<\?xml[^>]*>/, "")) do |config|
        config.huge
      end
      elem["src"] = ""
      elem.children = x
    end

    def figure1(elem)
      return sourcecode1(elem) if elem["class"] == "pseudocode" ||
        elem["type"] == "pseudocode"
      return if labelled_ancestor(elem) && elem.ancestors("figure").empty? ||
        elem.at(ns("./figure")) && !elem.at(ns("./name"))

      lbl = @xrefs.anchor(elem["id"], :label, false) or return
      prefix_name(elem, "&nbsp;&mdash; ",
                  l10n("#{lower2cap @i18n.figure} #{lbl}"), "name")
    end

    def svg_emf_double(img)
      if emf?(img["mimetype"])
        img = emf_encode(img)
        img.children.first.previous = emf_to_svg(img)
      elsif img["mimetype"] == "image/svg+xml"
        src = svg_to_emf(img) and img << "<emf src='#{src}'/>"
      end
    end

    def emf_encode(img)
      img["mimetype"] = "image/svg+xml"
      unless %r{^data:image}.match?(img["src"])
        img["src"] = Metanorma::Utils::datauri(img["src"])
      end
      img.children = "<emf src='#{img['src']}'/>"
      img["src"] = ""
      img
    end

    def emf_to_svg(img)
      emf = Metanorma::Utils::save_dataimage(img.at(ns("./emf/@src")).text)
      Emf2svg.from_file(emf).sub(/<\?[^>]+>/, "")
    end

    def svg_to_emf(node)
      uri = svg_to_emf_uri(node)
      ret = svg_to_emf_filename(uri)
      File.exists?(ret) and return ret
      exe = inkscape_installed? or return nil
      warn "2. #{uri}: #{File.exists?(uri)}"
      warn "2.1. #{external_path(uri)}"
      warn "Attempt on " + %(#{external_path exe} --export-type="emf" #{external_path uri})
      if system %(#{external_path exe} --export-type="emf" #{external_path uri})
        warn "3. #{ret}: #{File.exists?(ret)}"
        warn "3.1. #{external_path ret}: #{File.exists?(external_path ret)}"
        warn "4. #{Metanorma::Utils::datauri(ret)}"
        return Metanorma::Utils::datauri(ret)
      end
      warn "Fail on " + %(#{exe} --export-type="emf" #{uri})

      nil
    end

    def svg_to_emf_uri(node)
      uri = if node&.elements&.first&.name == "svg"
              a = Base64.strict_encode64(node.children.to_xml)
              "data:image/svg+xml;base64,#{a}"
            else node["src"]
            end
      if %r{^data:}.match?(uri)
        uri = save_dataimage(uri)
        @tempfile_cache << uri
        warn "1. #{uri}: #{File.exists?(uri)}"
      end
      uri
    end

    def svg_to_emf_filename(uri)
      "#{File.join(File.dirname(uri), File.basename(uri, '.*'))}.emf"
    end

    def emf_to_svgfilename(uri)
      "#{File.join(File.dirname(uri), File.basename(uri, '.*'))}.svg"
    end

    def inkscape_installed?
      cmd = "inkscape"
      exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
      ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      nil
    end
  end
end
