require "isodoc/html_function/mathvariant_to_plain"
require_relative "postprocess_footnotes"
require_relative "postprocess_cover"
require "metanorma-utils"
require "set"

module IsoDoc
  module HtmlFunction
    module Html
      def postprocess(result, filename, _dir)
        result = from_xhtml(cleanup(to_xhtml(textcleanup(result))))
        toHTML(result, filename)
        @files_to_delete.each { |f| FileUtils.rm_rf f }
      end

      def toHTML(result, filename)
        result = from_xhtml(html_cleanup(to_xhtml(result)))
        result = from_xhtml(process_images(to_xhtml(result)))
        result = html5(script_cdata(inject_script(result)))
        File.open(filename, "w:UTF-8") { |f| f.write(result) }
      end

      def html5(doc)
        doc.sub(%r{<!DOCTYPE html [^<>]+>}, "<!DOCTYPE html>")
          .sub(%r{<\?xml[^<>]+>}, "")
      end

      def html_cleanup(html)
        html = term_header(html_footnote_filter(html_preface(htmlstyle(html))))
        html = footnote_backlinks(html)
        html = mathml(html_list_clean(remove_placeholder_paras(html)))
        html_toc(heading_anchors(sourcecode_cleanup(html)))
      end

      def heading_anchors(html)
        html.xpath("//h1 | //h2 | //h3 | //h4 | //h5 | //h6 | //h7 | //h8 "\
                   "//span[@class = 'inline-header']").each do |h|
          h.at("./ancestor::div[@id='toc']") and next
          div = h.xpath("./ancestor::div[@id]")
          div.empty? and next
          heading_anchor(h, div[-1]["id"])
        end
        html
      end

      def heading_anchor(hdr, id)
        hdr.children = <<~HTML.strip
          <a class='anchor' href='##{id}'/><a class='header' href='##{id}'>#{hdr.children.to_xml}</a>
        HTML
      end

      def sourcecode_cleanup(html)
        ann = ".//div[@class = 'annotation']"
        html.xpath("//pre[#{ann}] | //div[@class = 'sourcecode'][#{ann}]")
          .each do |p|
          ins = p.after("<pre class='sourcecode'/>").next_element
          p.xpath(ann).each do |d|
            ins << d.remove.children
          end
        end
        html
      end

      def remove_placeholder_paras(html)
        %w(title-section prefatory-section).each do |s|
          html&.at("//div[@class = '#{s}']/p[last()]")&.remove
        end
        html
      end

      def html_list_clean(html)
        html.xpath("//ol/div | //ul/div").each do |div|
          li = div.xpath("./preceding-sibling::li")&.last ||
            div.at("./following-sibling::li")
          div.parent = li
        end
        html
      end

      def mathml(docxml)
        IsoDoc::HtmlFunction::MathvariantToPlain.new(docxml).convert
      end

      def process_images(docxml)
        svg_css_scoping(move_images(resize_images(docxml)))
      end

      # do not resize SVG, their height is set to 1px in HTML for autofit
      def resize_images(docxml)
        docxml.xpath("//*[local-name() = 'img']").each do |i|
          loc = image_localfile(i) or next
          i["width"], i["height"] = Vectory::ImageResize.new
            .call(i, loc, @maxheight, @maxwidth)
        end
        docxml
      end

      # presupposes that the image source is local
      def move_images(docxml)
        FileUtils.rm_rf tmpimagedir
        FileUtils.mkdir tmpimagedir
        docxml.xpath("//*[local-name() = 'img'][@src]").each do |i|
          /^data:/.match? i["src"] and next
          @datauriimage ? datauri(i) : move_image1(i)
        end
        docxml
      end

      def datauri(img)
        img["src"] = Vectory::Utils::datauri(img["src"], @localdir)
      end

      # Scope CSS class names in SVG elements to prevent conflicts
      def svg_css_scoping(docxml)
        svg_counter = 0
        docxml.xpath("//*[local-name() = 'svg'][.//style]").each do |svg|
          svg_counter += 1
          scope_svg_css_classes(svg, svg_counter)
        end
        docxml
      end

      private

      # Process a single SVG element to scope its CSS classes
      def scope_svg_css_classes(svg, counter)
        # Find all style elements within this SVG
        style_elements = svg.xpath(".//style")
        return if style_elements.empty?

        # Extract all class names from CSS and create mapping
        class_mapping = {}
        style_elements.each do |style|
          css_content = style.content
          extract_css_class_names(css_content).each do |class_name|
            scoped_name = "#{class_name}_svg_class_#{counter}"
            class_mapping[class_name] = scoped_name
          end
        end

        return if class_mapping.empty?

        # Update CSS definitions in style elements
        style_elements.each do |style|
          style.content = update_css_class_references(style.content, class_mapping)
        end

        # Update class attributes in SVG elements
        update_svg_class_attributes(svg, class_mapping)
      end

      # Extract all CSS class names from CSS content
      def extract_css_class_names(css_content)
        class_names = Set.new
        
        # Remove CSS comments
        css_content = css_content.gsub(/\/\*.*?\*\//m, "")
        
        # Find all class selectors (.classname)
        # This regex matches .classname but not pseudo-classes like :hover
        css_content.scan(/\.([a-zA-Z_][\w-]*)(?![:\w-])/) do |match|
          class_names.add(match[0])
        end
        
        class_names.to_a
      end

      # Update CSS content to use scoped class names
      def update_css_class_references(css_content, class_mapping)
        updated_css = css_content.dup
        
        class_mapping.each do |original, scoped|
          # Replace class selectors (.classname) with scoped versions
          # Use word boundaries to avoid partial matches
          updated_css.gsub!(/\.#{Regexp.escape(original)}(?![:\w-])/, ".#{scoped}")
        end
        
        updated_css
      end

      # Update class attributes in SVG elements
      def update_svg_class_attributes(svg, class_mapping)
        svg.xpath(".//*[@class]").each do |element|
          class_attr = element["class"]
          next if class_attr.nil? || class_attr.strip.empty?
          
          # Split multiple classes and update each one
          updated_classes = class_attr.split(/\s+/).map do |class_name|
            class_mapping[class_name] || class_name
          end
          
          element["class"] = updated_classes.join(" ")
        end
      end

      public

      # SVG to data URI so that their CSS definitions don't contaminate DOM
      def svg_data_uri(docxml)
        docxml.xpath("//*[local-name() = 'svg']").each do |i|
          uri = Vectory::Svg.from_content(i.to_xml).to_uri.content
          i.replace("<img src='#{uri}'/>")
        end
        docxml
      end

      def image_suffix(img)
        type = img["mimetype"]&.sub(%r{^[^/*]+/}, "")
        matched = /\.(?<suffix>[^. \r\n\t]+)$/.match img["src"]
        type and !type.empty? and return type
        !matched.nil? and matched[:suffix] and return matched[:suffix]
        "png"
      end

      def move_image1(img)
        suffix = image_suffix(img)
        uuid = UUIDTools::UUID.random_create.to_s
        fname = "#{uuid}.#{suffix}"
        new_full_filename = File.join(tmpimagedir, fname)
        local_filename = image_localfile(img)
        FileUtils.cp local_filename, new_full_filename
        img["src"] = File.join(rel_tmpimagedir, fname)
      end

      def term_header(docxml)
        %w(h1 h2 h3 h4 h5 h6 h7 h8).each do |h|
          docxml.xpath("//p[@class = 'TermNum'][../#{h}]").each do |p|
            p.name = "h#{h[1].to_i + 1}"
            id = p["id"]
            p["id"] = "_#{UUIDTools::UUID.random_create}"
            p.wrap("<div id='#{id}'></div>")
          end
        end
        docxml
      end
    end
  end
end
