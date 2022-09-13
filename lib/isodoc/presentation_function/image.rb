require "base64"
require "emf2svg"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    SVG = { "m" => "http://www.w3.org/2000/svg" }.freeze

    def figure(docxml)
      docxml.xpath("//m:svg", SVG).each { |f| svg_wrap(f) }
      docxml.xpath(ns("//image")).each { |f| svg_extract(f) }
      docxml.xpath(ns("//figure")).each { |f| figure1(f) }
      docxml.xpath(ns("//svgmap")).each { |s| svgmap_extract(s) }
      imageconvert(docxml)
    end

    def svg_wrap(elem)
      return if elem.parent.name == "image"

      elem.replace("<image src='' mimetype='image/svg+xml' height='auto' "\
                   "width='auto'>#{elem.to_xml}</image>")
    end

    def svgmap_extract(elem)
      if f = elem.at(ns("./figure")) then elem.replace(f)
      else elem.remove
      end
    end

    def imageconvert(docxml)
      docxml.xpath(ns("//image")).each do |f|
        eps2svg(f)
        svg_emf_double(f)
      end
    end

    def svg_extract(elem)
      return unless %r{^data:image/svg\+xml;}.match?(elem["src"])
      return if elem.at("./m:svg", SVG)

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
      return if elem.at(ns("./figure")) && !elem.at(ns("./name"))

      lbl = @xrefs.anchor(elem["id"], :label, false) or return
      prefix_name(elem, block_delim,
                  l10n("#{lower2cap @i18n.figure} #{lbl}"), "name")
    end

    def eps2svg(img)
      return unless eps?(img["mimetype"])

      img["mimetype"] = "image/svg+xml"
      if src = eps_to_svg(img)
        img["src"] = src
        img.children = ""
      end
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
      svg_prep(img)
      img.children = "<emf src='#{img['src']}'/>"
      img["src"] = ""
      img
    end

    def svg_prep(img)
      img["mimetype"] = "image/svg+xml"
      %r{^data:image}.match?(img["src"]) or
        img["src"] = Metanorma::Utils::datauri(img["src"])
    end

    def emf_to_svg(img)
      emf = Metanorma::Utils::save_dataimage(img.at(ns("./emf/@src")).text)
      Emf2svg.from_file(emf).sub(/<\?[^>]+>/, "")
    end

    def eps_to_svg(node)
      uri = eps_to_svg_uri(node)
      ret = imgfile_suffix(uri, "svg")
      File.exist?(ret) and return ret
      inkscape_convert(uri, ret, "--export-plain-svg")
    end

    def svg_to_emf(node)
      uri = svg_to_emf_uri(node)
      ret = imgfile_suffix(uri, "emf")
      File.exist?(ret) and return ret
      inkscape_convert(uri, ret, '--export-type="emf"')
    end

    def inkscape_convert(uri, file, option)
      exe = inkscape_installed? or raise "Inkscape missing in PATH, unable" \
                                         "to convert image #{uri}. Aborting."
      uri = Metanorma::Utils::external_path uri
      exe = Metanorma::Utils::external_path exe
      system(%(#{exe} #{option} #{uri})) and
        return Metanorma::Utils::datauri(file)

      raise %(Fail on #{exe} #{option} #{uri})
    end

    def svg_to_emf_uri(node)
      uri = svg_to_emf_uri_convert(node)
      cache_dataimage(uri)
    end

    def eps_to_svg_uri(node)
      uri = eps_to_svg_uri_convert(node)
      cache_dataimage(uri)
    end

    def cache_dataimage(uri)
      if %r{^data:}.match?(uri)
        uri = save_dataimage(uri)
        @tempfile_cache << uri
      end
      uri
    end

    def svg_to_emf_uri_convert(node)
      if node&.elements&.first&.name == "svg"
        a = Base64.strict_encode64(node.children.to_xml)
        "data:image/svg+xml;base64,#{a}"
      else node["src"]
      end
    end

    def eps_to_svg_uri_convert(node)
      if node.text.strip.empty?
        node["src"]
      else
        a = Base64.strict_encode64(node.children.to_xml)
        "data:application/postscript;base64,#{a}"
      end
    end

    def imgfile_suffix(uri, suffix)
      "#{File.join(File.dirname(uri), File.basename(uri, '.*'))}.#{suffix}"
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
