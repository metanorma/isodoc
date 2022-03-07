require_relative "inline_simple"

module IsoDoc
  module Function
    module Inline
      def link_parse(node, out)
        url = node["target"]
        node["update-type"] == "true" and url = suffix_url(url)
        out.a **attr_code(href: url, title: node["alt"]) do |l|
          if node.text.empty?
            l << node["target"].sub(/^mailto:/, "")
          else node.children.each { |n| parse(n, l) }
          end
        end
      end

      def callout_parse(node, out)
        out << " &lt;#{node.text}&gt;"
      end

      def no_locality_parse(node, out)
        node.children.each do |n|
          parse(n, out) unless %w{locality localityStack}.include? n.name
        end
      end

      def xref_parse(node, out)
        target = if /#/.match?(node["target"])
                   node["target"].sub(/#/, ".html#")
                 else
                   "##{node['target']}"
                 end
        out.a(**{ href: target }) { |l| no_locality_parse(node, l) }
      end

      def suffix_url(url)
        return url if url.nil? || %r{^https?://|^#}.match?(url)
        return url unless File.extname(url).empty?

        url.sub(/#{File.extname(url)}$/, ".html")
      end

      def eref_target(node)
        url = suffix_url(eref_url(node["bibitemid"]))
        anchor = node&.at(ns(".//locality[@type = 'anchor']"))
        return url if url.nil? || /^#/.match?(url) || !anchor

        "#{url}##{anchor.text.strip}"
      end

      def eref_url(bibitemid)
        return nil if @bibitems.nil? || @bibitems[bibitemid].nil?

        if url = @bibitems[bibitemid].at(ns("./uri[@type = 'citation']"))
          url.text
        elsif @bibitems[bibitemid]["hidden"] == "true"
          @bibitems[bibitemid]&.at(ns("./uri"))&.text
        else "##{bibitemid}"
        end
      end

      def eref_parse(node, out)
        if href = eref_target(node)
          if node["type"] == "footnote"
            out.sup do |s|
              s.a(**{ href: href }) { |l| no_locality_parse(node, l) }
            end
          else
            out.a(**{ href: href }) { |l| no_locality_parse(node, l) }
          end
        else no_locality_parse(node, out)
        end
      end

      def origin_parse(node, out)
        if t = node.at(ns("./termref"))
          termrefelem_parse(t, out)
        else
          eref_parse(node, out)
        end
      end

      def termrefelem_parse(node, out)
        if node.text.strip.empty?
          out << "Termbase #{node['base']}, term ID #{node['target']}"
        else
          node.children.each { |n| parse(n, out) }
        end
      end

      def stem_parse(node, out)
        ooml = case node["type"]
               when "AsciiMath"
                 "#{@openmathdelim}#{HTMLEntities.new.encode(node.text)}"\
                 "#{@closemathdelim}"
               when "MathML" then node.first_element_child.to_s
               else HTMLEntities.new.encode(node.text)
               end
        out.span **{ class: "stem" } do |span|
          span.parent.add_child ooml
        end
      end

      def image_title_parse(out, caption)
        unless caption.nil?
          out.p **{ class: "FigureTitle", style: "text-align:center;" } do |p|
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
        out.img **attr_code(attrs)
        image_title_parse(out, caption)
      end

      def smallcap_parse(node, xml)
        xml.span **{ style: "font-variant:small-caps;" } do |s|
          node.children.each { |n| parse(n, s) }
        end
      end

      def text_parse(node, out)
        return if node.nil? || node.text.nil?

        text = node.to_s
        if in_sourcecode
          text = text.gsub("\n", "<br/>").gsub("<br/> ", "<br/>&nbsp;")
            .gsub(/ (?= )/, "&nbsp;")
        end
        out << text
      end

      def add_parse(node, out)
        out.span **{ class: "addition" } do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def del_parse(node, out)
        out.span **{ class: "deletion" } do |e|
          node.children.each { |n| parse(n, e) }
        end
      end

      def error_parse(node, out)
        text = node.to_xml.gsub(/</, "&lt;").gsub(/>/, "&gt;")
        out.para do |p|
          p.b(**{ role: "strong" }) { |e| e << text }
        end
      end
    end
  end
end
