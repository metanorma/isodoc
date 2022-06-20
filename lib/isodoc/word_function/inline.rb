module IsoDoc
  module WordFunction
    module Body
      def section_break(body, continuous: false)
        body.p do |p|
          if continuous
            p.br **{ clear: "all", style: "page-break-before:auto;"\
                                          "mso-break-type:section-break" }
          else
            p.br **{ clear: "all", class: "section" }
          end
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
          p.br **{ clear: "all", class: "section",
                   orientation: node["orientation"] }
        end
      end

      def imgsrc(node)
        return node["src"] unless %r{^data:}.match? node["src"]

        save_dataimage(node["src"])
      end

      def image_parse(node, out, caption)
        if emf = node.at(ns("./emf"))
          node["src"] = emf["src"]
          node["mimetype"] = "image/x-emf"
          node.children.remove
        end
        attrs = { src: imgsrc(node),
                  height: node["height"], alt: node["alt"],
                  title: node["title"], width: node["width"] }
        out.img **attr_code(attrs)
        image_title_parse(out, caption)
      end

      def xref_parse(node, out)
        target = if /#/.match?(node["target"])
                   node["target"].sub(/#/, ".doc#")
                 else
                   "##{node['target']}"
                 end
        out.a(**{ href: target }) do |l|
          node.children.each { |n| parse(n, l) }
        end
      end
    end
  end
end
