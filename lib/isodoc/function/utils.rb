require "metanorma-utils"
require_relative "utils_img"

module IsoDoc
  module Function
    module Utils
      Hash.include Metanorma::Utils::Hash
      Array.include Metanorma::Utils::Array

      def to_xml(node)
        self.class.to_xml(node)
      end

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
        tab = %w(Hans Hant Jpan Kore).include?(@script) ? "&#x3000;" : "&#xa0; "
        [1..count].each { out << tab }
      end

      def noko(&)
        Metanorma::Utils::noko_html(&)
      end

      def attr_code(attributes)
        attributes.compact.transform_values do |v|
          v.is_a?(String) ? HTMLEntities.new.decode(v) : v
        end
      end

      DOCTYPE_HDR = "<!DOCTYPE html SYSTEM " \
                    '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'.freeze

      HUGESTRICT = Nokogiri::XML::ParseOptions::HUGE |
        Nokogiri::XML::ParseOptions::STRICT

      def to_xhtml(xml)
        xml = to_xhtml_prep(xml)
        begin
          Nokogiri::XML.parse(xml, nil, nil, HUGESTRICT)
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
        xml.gsub!(/\A<\?xml[^<>]*>\n?/, "")
        xml.include?("<!DOCTYPE ") || (xml = DOCTYPE_HDR + xml)
        numeric_escapes(xml)
      end

      def to_xhtml_fragment(xml)
        Metanorma::Utils::to_xhtml_fragment(xml)
      end

      def from_xhtml(xml)
        numeric_escapes(to_xml(xml)
          .sub(%r{ xmlns="http://www.w3.org/1999/xhtml"}, ""))
      end

      CLAUSE_ANCESTOR = <<~XPATH.strip.freeze
        .//ancestor::*[local-name() = 'annex' or local-name() = 'definitions' or local-name() = 'executivesummary' or local-name() = 'acknowledgements' or local-name() = 'term' or local-name() = 'appendix' or local-name() = 'foreword' or local-name() = 'introduction' or local-name() = 'terms' or local-name() = 'clause' or local-name() = 'references']/@id
      XPATH

      def get_clause_id(node)
        node.xpath(CLAUSE_ANCESTOR)&.last&.text || nil
      end

      NOTE_CONTAINER_ANCESTOR = <<~XPATH.strip.freeze
        .//ancestor::*[local-name() = 'annex' or local-name() = 'foreword' or local-name() = 'appendix' or local-name() = 'introduction' or local-name() = 'terms' or local-name() = 'acknowledgements' or local-name() = 'executivesummary' or local-name() = 'term' or local-name() = 'clause' or local-name() = 'references' or local-name() = 'figure' or local-name() = 'formula' or local-name() = 'table' or local-name() = 'example' or local-name() = 'bibitem']/@id
      XPATH

      # no recursion on references
      def get_note_container_id(node, type)
        xpath = NOTE_CONTAINER_ANCESTOR.dup
        %w(figure table example).include?(type) and
          xpath.sub!(%r[ or local-name\(\) = '#{type}'], "")
        container = node.xpath(xpath)
        container&.last&.text || nil
      end

      def sentence_join(array)
        array.nil? || array.empty? and return ""
        if array.length == 1 then array[0]
        else
          @i18n.l10n("#{array[0..-2].join(', ')} #{@i18n.and} #{array.last}",
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
        # \s[^<>]* rather than \s[^<>]+: \s already guarantees one whitespace
        # char after <p, so [^<>]* (zero or more) suffices for any attributes,
        # and removes the polynomial interaction between \s and [^<>]+.
        h1 = to_xhtml_fragment(hdr.to_s.gsub(%r{<br\s*/>}, " ")
          .gsub(%r{</?p(\s[^<>]*)?>}, "")
          .gsub(/<\/?h[123456][^<>]*>/, "").dup)
        h1.traverse do |x|
          if x.name == "span" && x["style"]&.include?("mso-tab-count")
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
          (elem.name == "span" && elem["style"]&.include?("mso-bookmark"))
      end

      def liquid(doc)
        # unescape HTML escapes in doc
        doc = doc.split(%r<(\{%|%\})>).each_slice(4).map do |a|
          a[2] = a[2].gsub("&lt;", "<").gsub("&gt;", ">") if a.size > 2
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
        liquid(docxml).render(meta.stringify_all_keys
          .transform_values { |v| empty2nil(v) })
          .gsub("&lt;", "&#x3c;").gsub("&gt;", "&#x3e;").gsub("&amp;", "&#x26;")
      end

      LABELLED_ANCESTOR_ELEMENTS =
        %w(example requirement recommendation permission
           note table figure sourcecode).freeze

      def labelled_ancestor(elem, exceptions = [])
        !elem.ancestors.map(&:name)
          .intersection(LABELLED_ANCESTOR_ELEMENTS - exceptions).empty?
      end

      def cleanup_entities(text, is_xml: true)
        c = HTMLEntities.new
        if is_xml
          text.split(/([<>])/).each_slice(4).map do |a|
            a[0] = c.encode(c.decode(a[0]), :hexadecimal)
            a
          end.join
        else c.encode(c.decode(text), :hexadecimal)
        end
      end

      def external_path(path)
        win = !!((RUBY_PLATFORM =~ /(win|w)(32|64)$/) ||
                 (RUBY_PLATFORM =~ /mswin|mingw/))
        win or return path
        path.tr!(%{/}, "\\")
        path[/\s/] ? "\"#{path}\"" : path
      end

      # Unescape &#x26; to & in href attributes only
      # This ensures URLs work correctly while preserving &#x26; in text content
      # This operates on the final string output after all Nokogiri processing
      def unescape_amp_in_hrefs(html)
        # Match href="..." and href='...' separately
        # Note: populate_template converts &amp; to &#x26;, so we replace that
        html.gsub(/(href\s*=\s*")([^"]*)"|(href\s*=\s*')([^']*)'/) do
          if Regexp.last_match(1)
            "#{Regexp.last_match(1)}#{Regexp.last_match(2).gsub('&#x26;',
                                                                '&')}\""
          else
            "#{Regexp.last_match(3)}#{Regexp.last_match(4).gsub('&#x26;',
                                                                '&')}'"
          end
        end
      end

      # parse CSV-encoded key=value attribute
      COMMA_PLACEHOLDER = "##COMMA##".freeze

      # Temporarily replace commas inside quotes with a placeholder
      def comma_placeholder(options)
        processed = ""
        in_quotes = false
        options.each_char do |c|
          c == "'" and in_quotes = !in_quotes
          processed << if c == "," && in_quotes
                         COMMA_PLACEHOLDER
                       else c
                       end
        end
        processed
      end

      def csv_attribute_extract(options)
        options.gsub!(/([a-z_]+)='/, %('\\1=))
        processed = comma_placeholder(options)
        CSV.parse_line(processed, quote_char: "'")
          .each_with_object({}) do |x, acc|
          x.gsub!(COMMA_PLACEHOLDER, ",")
          m = /^(.+?)=(.*)?$/.match(x) or next
          acc[m[1].to_sym] = m[2].sub(/^(["'])(.+)\1$/, "\\2")
        end
      end
    end
  end
end
