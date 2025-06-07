module IsoDoc
  module WordFunction
    module Body
      def insert_tab(out, count)
        out.span **attr_code(style: "mso-tab-count:#{count}") do |span|
          [1..count].each { span << "&#xA0; " }
        end
      end

      def section_break(body, continuous: false)
        body.p class: "section-break" do |p|
          if continuous
            p.br clear: "all", style: "page-break-before:auto;" \
                                      "mso-break-type:section-break"
          else
            p.br clear: "all", class: "section"
          end
        end
      end

      def page_break(out)
        out.p class: "page-break" do |p|
          p.br clear: "all",
               style: "mso-special-character:line-break;" \
                      "page-break-before:always"
        end
      end

      def pagebreak_parse(node, out)
        return page_break(out) if node["orientation"].nil?

        out.p do |p|
          p.br clear: "all", class: "section",
               orientation: node["orientation"]
        end
      end

      def imgsrc(node)
        return node["src"] unless %r{^data:}.match? node["src"]

        save_dataimage(node["src"])
      end

      def image_parse(node, out, caption)
        emf_attributes(node)
        attrs = { src: imgsrc(node),
                  height: node["height"], alt: node["alt"],
                  title: node["title"], width: node["width"] }
        out.img **attr_code(attrs)
        image_title_parse(out, caption)
      end

      def emf_attributes(node)
        if emf = node.at(ns("./emf"))
          node["src"] = emf["src"]
          node["height"] ||= emf["height"]
          node["width"] ||= emf["width"]
          node["mimetype"] = "image/x-emf"
          node.children.remove
        end
      end

      def xref_parse(node, out)
        target = if node["target"].include?("#")
                   node["target"].sub("#", ".doc#")
                 else
                   "##{node['target']}"
                 end
        out.a(href: target) do |l|
          children_parse(node, l)
        end
      end

      def suffix_url(url)
        return url if url.nil? || %r{^https?://|^#}.match?(url)
        return url unless File.extname(url).empty?

        url.sub(/#{File.extname(url)}$/, ".doc")
      end

      def ruby_parse(node, out)
        if r = node.at(ns("./rb[ruby]"))
          double_ruby = r.at(ns("./ruby/rt")).remove
          r.replace(r.at(ns("./ruby/rb")))
        end
        out.ruby do |e|
          children_parse(node, e)
        end
        double_ruby and out << "(#{double_ruby.text})"
      end

      def rt_parse(node, out)
        out.rt **{ style: "font-size: 6pt;" } do |e|
          children_parse(node, e)
        end
      end
    end
  end
end
