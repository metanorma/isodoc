require "metanorma-utils"

module IsoDoc
  module Function
    module Utils
      def date_range(date)
        self.class.date_range(date)
      end

      def ns(xpath)
        self.class.ns(xpath)
      end

      def start_of_sentence(node)
        self.class.start_of_sentence(node)
      end

      def insert_tab(out, count)
        tab = %w(Hans Hant).include?(@script) ? "&#x3000;" : "&#xa0; "
        [1..count].each { out << tab }
      end

      def noko(&block)
        Metanorma::Utils::noko_html(&block)
      end

      def attr_code(attributes)
        attributes.compact.transform_values do |v|
          v.is_a?(String) ? HTMLEntities.new.decode(v) : v
        end
      end

      DOCTYPE_HDR = "<!DOCTYPE html SYSTEM " \
                    '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'.freeze

      def to_xhtml(xml)
        xml = to_xhtml_prep(xml)
        begin
          Nokogiri::XML.parse(xml, &:strict)
        rescue Nokogiri::XML::SyntaxError => e
          File.open("#{@filename}.#{@format}.err", "w:UTF-8") do |f|
            f.write xml
          end
          abort "Malformed Output XML for #{@format}: #{e} " \
                "(see #{@filename}.#{@format}.err)"
        end
      end

      def numeric_escapes(xml)
        Metanorma::Utils::numeric_escapes(xml)
      end

      def to_xhtml_prep(xml)
        xml.gsub!(/<\?xml[^>]*>/, "")
        /<!DOCTYPE /.match(xml) || (xml = DOCTYPE_HDR + xml)
        numeric_escapes(xml)
      end

      def to_xhtml_fragment(xml)
        Metanorma::Utils::to_xhtml_fragment(xml)
      end

      def from_xhtml(xml)
        numeric_escapes(xml.to_xml
          .sub(%r{ xmlns="http://www.w3.org/1999/xhtml"}, ""))
      end

      CLAUSE_ANCESTOR =
        ".//ancestor::*[local-name() = 'annex' or " \
        "local-name() = 'definitions' or " \
        "local-name() = 'acknowledgements' or local-name() = 'term' or " \
        "local-name() = 'appendix' or local-name() = 'foreword' or " \
        "local-name() = 'introduction' or local-name() = 'terms' or " \
        "local-name() = 'clause' or local-name() = 'references']/@id".freeze

      def get_clause_id(node)
        node.xpath(CLAUSE_ANCESTOR)&.last&.text || nil
      end

      NOTE_CONTAINER_ANCESTOR =
        ".//ancestor::*[local-name() = 'annex' or " \
        "local-name() = 'foreword' or local-name() = 'appendix' or " \
        "local-name() = 'introduction' or local-name() = 'terms' or " \
        "local-name() = 'acknowledgements' or local-name() = 'term' or " \
        "local-name() = 'clause' or local-name() = 'references' or " \
        "local-name() = 'figure' or local-name() = 'formula' or " \
        "local-name() = 'table' or local-name() = 'example']/@id".freeze

      # no recursion on references
      def get_note_container_id(node, type)
        xpath = NOTE_CONTAINER_ANCESTOR.dup
        %w(figure table example).include?(type) and
          xpath.sub!(%r[ or local-name\(\) = '#{type}'], "")
        container = node.xpath(xpath)
        container&.last&.text || nil
      end

      def sentence_join(array)
        return "" if array.nil? || array.empty?

        if array.length == 1 then array[0]
        else
          @i18n.l10n("#{array[0..-2].join(', ')} " \
                     "#{@i18n.and} #{array.last}",
                     @lang, @script)
        end
      end

      # avoid `; avoid {{ (Liquid Templates); avoid [[ (Javascript)
      def extract_delims(text)
        @openmathdelim = "(#("
        @closemathdelim = ")#)"
        while text.include?(@openmathdelim) || text.include?(@closemathdelim)
          @openmathdelim += "("
          @closemathdelim += ")"
        end
        [@openmathdelim, @closemathdelim]
      end

      def header_strip(hdr)
        h1 = to_xhtml_fragment(hdr.to_s.gsub(%r{<br\s*/>}, " ")
          .gsub(%r{</?p(\s[^>]+)?>}, "")
          .gsub(/<\/?h[123456][^>]*>/, "").gsub(/<\/?b[^>]*>/, "").dup)
        h1.traverse do |x|
          if x.name == "span" && /mso-tab-count/.match(x["style"])
            x.replace(" ")
          elsif header_strip_elem?(x) then x.remove
          elsif x.name == "a" then x.replace(x.children)
          end
        end
        from_xhtml(h1)
      end

      def header_strip_elem?(elem)
        elem.name == "img" ||
          (elem.name == "span" && elem["class"] == "MsoCommentReference") ||
          (elem.name == "a" && elem["class"] == "FootnoteRef") ||
          (elem.name == "span" && /mso-bookmark/.match(elem["style"]))
      end

      def liquid(doc)
        # unescape HTML escapes in doc
        doc = doc.split(%r<(\{%|%\})>).each_slice(4).map do |a|
          a[2] = a[2].gsub(/&lt;/, "<").gsub(/&gt;/, ">") if a.size > 2
          a.join
        end.join
        Liquid::Template.parse(doc)
      end

      def empty2nil(str)
        !str.nil? && str.is_a?(String) && str.empty? and return nil
        str
      end

      def populate_template(docxml, _format = nil)
        meta = @meta
          .get
          .merge(@labels ? { labels: @labels } : {})
          .merge(@meta.labels ? { labels: @meta.labels } : {})
          .merge(fonts_options || {})
        template = liquid(docxml)
        template.render(meta.map { |k, v| [k.to_s, empty2nil(v)] }.to_h)
          .gsub("&lt;", "&#x3c;").gsub("&gt;", "&#x3e;").gsub("&amp;", "&#x26;")
      end

      def save_dataimage(uri, _relative_dir = true)
        %r{^data:(?<imgclass>image|application)/(?<imgtype>[^;]+);(?:charset=[^;]+;)?base64,(?<imgdata>.+)$} =~ uri
        imgtype = "emf" if emf?("#{imgclass}/#{imgtype}")
        imgtype = imgtype.sub(/\+[a-z0-9]+$/, "") # svg+xml
        imgtype = "png" unless /^[a-z0-9]+$/.match? imgtype
        Tempfile.open(["image", ".#{imgtype}"]) do |f|
          f.binmode
          f.write(Base64.strict_decode64(imgdata))
          @tempfile_cache << f # persist to the end
          f.path
        end
      end

      def save_svg(img)
        Tempfile.open(["image", ".svg"]) do |f|
          f.write(img.to_xml)
          @tempfile_cache << f # persist to the end
          f.path
        end
      end

      def image_localfile(img)
        img.name == "svg" && !img["src"] and
          return save_svg(img)
        case img["src"]
        when /^data:/ then save_dataimage(img["src"], false)
        when %r{^([A-Z]:)?/} then img["src"]
        else File.join(@localdir, img["src"])
        end
      end

      def labelled_ancestor(node)
        !node.ancestors("example, requirement, recommendation, permission, " \
                        "note, table, figure, sourcecode").empty?
      end

      def emf?(type)
        %w(application/emf application/x-emf image/x-emf image/x-mgx-emf
           application/x-msmetafile image/x-xbitmap image/emf).include? type
      end

      def eps?(type)
        %w(application/postscript image/x-eps).include? type
      end

      def cleanup_entities(text, is_xml: true)
        c = HTMLEntities.new
        if is_xml
          text.split(/([<>])/).each_slice(4).map do |a|
            a[0] = c.encode(c.decode(a[0]), :hexadecimal)
            a
          end.join
        else
          c.encode(c.decode(text), :hexadecimal)
        end
      end

      def external_path(path)
        win = !!((RUBY_PLATFORM =~ /(win|w)(32|64)$/) ||
                 (RUBY_PLATFORM =~ /mswin|mingw/))
        if win
          path.gsub!(%{/}, "\\")
          path[/\s/] ? "\"#{path}\"" : path
        else path
        end
      end
    end
  end
end
