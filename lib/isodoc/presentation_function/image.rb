require "base64"

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

      elem.wrap("<image src='' mimetype='image/svg+xml' height='auto' " \
                "width='auto'></image>")
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
      x = Nokogiri::XML.fragment(svg.sub(/<\?xml[^<>]*>/, ""), &:huge)
      elem["src"] = ""
      elem.children = x
    end

    def figure1(elem)
      elem["class"] == "pseudocode" || elem["type"] == "pseudocode" and
        return sourcecode1(elem)
      figure_fn(elem)
      figure_key(elem.at(ns("./dl")))
      #figure_label?(elem) or return nil
      #lbl = @xrefs.anchor(elem["id"], :label, false) or return
      lbl = @xrefs.anchor(elem["id"], :label, false)
      lbl and a = autonum(elem["id"], lbl)
      # no xref, no label: this can be set in xref
      lbl && figure_label?(elem) and
        s = "<span class='fmt-element-name'>#{figure_label(elem)}</span> #{a}"
      prefix_name(elem, { caption: block_delim }, l10n(s&.strip), "name")
    end

    # move footnotes into key, and get rid of footnote reference
    # since it is in diagram
    def figure_fn(elem)
      fn = elem.xpath(ns(".//fn")) - elem.xpath(ns("./name//fn"))
      fn.empty? and return
      dl = figure_key_insert_pt(elem)
      fn.each do |f|
        dl.previous = "<dt><p><sup>#{f['reference']}</sup></p></dt>" \
          "<dd>#{f.remove.children.to_xml}</dd>"
      end
    end

    def figure_key_insert_pt(elem)
      elem.at(ns("//dl/name"))&.next ||
        elem.at(ns("//dl"))&.children&.first ||
        elem.add_child("<dl> </dl>").first.children.first
    end

    def figure_label?(elem)
      elem.at(ns("./figure")) && !elem.at(ns("./name")) and return false
      true
    end

    def figure_label(elem)
      klass = elem["class"] || "figure"
      klasslbl = @i18n.get[klass] || klass
      lower2cap klasslbl
    end

    def figure_key(dlist)
      dlist or return
      dlist["class"] = "formula_dl"
      dlist.at(ns("./name")) and return
      dlist.previous =
        "<p keep-with-next='true'><strong>#{@i18n.key}</strong></p>"
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
        # img.children.first.previous = emf_to_svg(img)
        img.add_first_child emf_to_svg(img)
      elsif img["mimetype"] == "image/svg+xml"
        src = svg_to_emf(img) or return
        img.add_child("<emf/>")
        img.elements.last["src"] = src
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
      %r{^data:}.match?(img["src"]) or
        img["src"] = Vectory::Emf.from_path(img["src"]).to_uri.content
    end

    def emf_to_svg(img)
      datauri_src = img.at(ns("./emf/@src")).text
      Vectory::Emf.from_datauri(datauri_src)
        .to_svg
        .content
        .sub(/<\?[^>]+>/, "")
    end

    def eps_to_svg(node)
      if !node.text.strip.empty? || %r{^data:}.match?(node["src"])
        return eps_to_svg_from_node(node)
      end

      target_path = imgfile_suffix(node["src"], "svg")
      return target_path if File.exist?(target_path)

      eps_to_svg_from_node(node, target_path)
    end

    def eps_to_svg_from_node(node, target_path = nil)
      svg = Vectory::Eps.from_node(node).to_svg
      return svg.write(target_path).path if target_path

      svg.write.path
    end

    def svg_to_emf(node)
      @output_formats[:doc] or return
      svg_impose_height_attr(node)
      node.elements&.first&.name == "svg" || %r{^data:}.match?(node["src"]) and
        return svg_to_emf_from_node(node)
      target_path = imgfile_suffix(node["src"], "emf")
      File.exist?(target_path) and return target_path
      svg_to_emf_from_node(node, target_path)
    end

    def svg_to_emf_from_node(node, target_path = nil)
      emf = Vectory::Svg.from_node(node).to_emf
      return emf.write(target_path).to_uri.content if target_path

      emf.to_uri.content
    end

    def svg_impose_height_attr(node)
      e = node.elements&.first or return
      (e.name == "svg" &&
        (!node["height"] || node["height"] == "auto")) or return
      node["height"] = e["height"]
      node["width"] = e["width"]
    end

    def imgfile_suffix(uri, suffix)
      "#{File.join(File.dirname(uri), File.basename(uri, '.*'))}.#{suffix}"
    end
  end
end
