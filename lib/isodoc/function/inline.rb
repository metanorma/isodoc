require_relative "inline_simple"

module IsoDoc
  module Function
    module Inline
      def link_parse(node, out)
        url = node["target"]
        node["update-type"] == "true" and url = suffix_url(url)
        out.a **attr_code(href: url, title: node["alt"]) do |l|
          if node.elements.empty? && node.text.strip.empty?
            l << @c.encode(node["target"].sub(/^mailto:/, ""), :basic,
                           :hexadecimal)
          else node.children.each { |n| parse(n, l) }
          end
        end
      end

      def location_parse(node, out); end

      # Presentation XML classes which we need not pass on to HTML or DOC
      SPAN_UNWRAP_CLASSES =
        %w[fmt-caption-label fmt-label-delim fmt-caption-delim fmt-autonum-delim
           fmt-element-name fmt-conn fmt-comma fmt-enum-comma fmt-obligation]
        .freeze

      def span_parse(node, out)
        klass = node["style"] || node["class"]
        if klass && !SPAN_UNWRAP_CLASSES.include?(klass)
          out.span **attr_code(style: node["style"],
                               class: node["class"]) do |s|
            children_parse(node, s)
          end
        else children_parse(node, out)
        end
      end

      # todo PRESENTATION XML
      def callout_parse(node, out)
        out << " &lt;#{node.text}&gt;"
      end

      def no_locality_parse(node, out)
        node.children.each do |n|
          parse(n, out) unless %w{locality localityStack}.include? n.name
        end
      end

      def xref_parse(node, out)
        target = if node["target"].include?("#")
                   node["target"].sub("#", ".html#")
                 else
                   "##{node['target']}"
                 end
        out.a(href: target) { |l| no_locality_parse(node, l) }
      end

      def suffix_url(url)
        url.nil? || %r{^https?://|^#}.match?(url) and return url
        File.extname(url).empty? or return url
        url.sub(/#{File.extname(url)}$/, ".html")
      end

      def eref_parse(node, out)
        no_locality_parse(node, out)
      end

      def origin_parse(node, out)
        if t = node.at(ns("./termref"))
          termrefelem_parse(t, out)
        else
          no_locality_parse(node, out)
        end
      end

      # todo PRESENTATION XML
      def termrefelem_parse(node, out)
        if node.text.strip.empty?
          out << "Termbase #{node['base']}, term ID #{node['target']}"
        else
          node.children.each { |n| parse(n, out) }
        end
      end

      def stem_parse(node, out)
        ooml = case node["type"]
               when "AsciiMath" then asciimath_parse(node)
               when "MathML" then mathml_parse(node)
               when "LaTeX" then latexmath_parse(node)
               else HTMLEntities.new.encode(node.text)
               end
        out.span class: "stem" do |span|
          span.parent.add_child ooml
        end
      end

      MATHML = { "m" => "http://www.w3.org/1998/Math/MathML" }.freeze

      def mathml_parse(node)
        # node.xpath("./m:math", MATHML).map(&:to_xml).join
        node.xpath(ns("./asciimath | ./latexmath")).each(&:remove)
        node.xpath(ns("./br")).each { |e| e.namespace = nil }
        node.elements
      end

      def asciimath_parse(node)
        a = node.at(ns("./asciimath"))&.text || node.text
        "#{@openmathdelim}#{HTMLEntities.new.encode(a)}" \
          "#{@closemathdelim}"
      end

      def latexmath_parse(node)
        a = node.at(ns("./latexmath"))&.text || node.text
        HTMLEntities.new.encode(a)
      end

      def image_title_parse(out, caption)
        unless caption.nil?
          out.p class: "FigureTitle", style: "text-align:center;" do |p|
            p.b { |b| b << caption.to_s }
          end
        end
      end

      def image_parse(node, out, caption)
        attrs = { src: node["src"],
                  height: node["height"] || "auto",
                  width: node["width"] || "auto",
                  title: node["title"],
                  alt: node["alt"] }
        image_body_parse(node, attrs, out)
        image_title_parse(out, caption)
      end

      def image_body_parse(_node, attrs, out)
        out.img **attr_code(attrs)
      end

      def smallcap_parse(node, xml)
        xml.span style: "font-variant:small-caps;" do |s|
          node.children.each { |n| parse(n, s) }
        end
      end

      def text_parse(node, out)
        node.nil? || node.text.nil? and return
        text = node.to_s
        @sourcecode == "pre" and
          text = text.gsub("\n", "<br/>").gsub("<br/> ", "<br/>&#xa0;")
        @sourcecode and
          text = text.gsub(/ (?= )/, "&#xa0;")
        out << text
      end

      def add_parse(node, out)
        out.span class: "addition" do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def del_parse(node, out)
        out.span class: "deletion" do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def error_parse(node, out)
        text = node.to_xml.gsub("<", "&lt;").gsub(">", "&gt;")
        out.para do |p|
          p.b(role: "strong") { |e| e << text }
        end
      end

      def ruby_parse(node, out)
        out.ruby do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def rt_parse(node, out)
        out.rt do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def rb_parse(node, out)
        out.rb do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def author_parse(node, out)
        children_parse(node, out)
      end

      def semx_parse(node, out)
        children_parse(node, out)
      end

      def children_parse(node, out)
        node.children.each { |n| parse(n, out) }
      end

      def xref_label_parse(node, out); end

      def name_parse(node, out); end
    end
  end
end
