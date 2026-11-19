# frozen_string_literal: true

require "moxml"
require "relaton"
require "relaton/bib"

module IsoDoc
  # bibdata ingestion through relaton's library surface.
  #
  # Mirrors the flavor dispatch of the relaton Cli entry point
  # (cli.rb parse_xml): the processor is named by the first
  # docidentifier's type, else by the leading word of its text. The
  # user-facing Relaton::Cli layer must not be called from library
  # code — relaton 3.1.6+ (#581) tightened Cli.parse_xml to a String
  # contract, and its Moxml path calls .read on non-string input, so a
  # Nokogiri document died NoMethodError on every compile and
  # bibdata_hash_parse rescued it into a silently nil Liquid bibdata.
  # The same dispatch lives in metanorma's Collection::Config::BibdataParser
  # (metanorma#716); the long-term home for both is a relaton
  # library-level API.
  module BibdataParser
    class << self
      # @param xml [String] serialized bibdata or bibitem XML
      # @return [Relaton::Bib::ItemData, nil] nil when the source is not
      #   parseable XML
      def from_xml(xml)
        return unless xml

        dispatch(Moxml.new.parse(xml))
      rescue Moxml::ParseError
        nil
      end

      private

      def dispatch(doc)
        plain = without_namespaces(doc)
        if (processor = processor_for_xml(doc))
          processor.from_xml(plain)
        else
          # No-flavor fallback: unparseable sources degrade to a nil
          # bibdata, as in the mirrored Cli method.
          no_flavor_fallback(plain)
        end
      end

      # The processor named by the first docidentifier's type, else by
      # the first word of its text.
      def processor_for_xml(doc)
        docid = doc.xpath("//*[local-name()='docidentifier']").first
        proc = get_proc(docid)
        return proc if proc

        text = docid&.text
        Relaton::Db::Registry.instance.by_type(text&.match(/^\w+/)&.to_s)
      end

      def no_flavor_fallback(plain)
        Relaton::Bib::Item.from_xml(plain)
      rescue StandardError
        nil
      end

      def get_proc(docid)
        type = docid&.[]("type")
        return unless type

        Relaton::Db::Registry.instance.by_type(type)
      end

      # The root element as XML, with every element and attribute in no
      # namespace (`xml:` attributes keep their prefix). The lutaml-model
      # mappings are namespace-free: they skip a prefixed element, and a
      # nested `relation/bibitem` in a default namespace raises in
      # lutaml-model 0.8.175. Moxml cannot drop a namespace in place, so
      # this builds a copy. (Mirror of relaton cli.rb without_namespaces.)
      def without_namespaces(doc)
        plain = Moxml.new.create_document
        plain.add_child plain_element(plain, doc.root)
        plain.root.to_xml
      end

      def plain_element(doc, src)
        elm = doc.create_element(src.name)
        # An attribute in no namespace wins over a prefixed one of the
        # same local name (`type` over `a:type`).
        src.attributes.sort_by { |a| a.namespace ? 0 : 1 }.each do |attr|
          elm[plain_name(attr)] = attr.value
        end
        src.children.each { |child| elm.add_child plain_node(doc, child) }
        elm
      end

      # The local name; an `xml:` attribute keeps its prefix.
      def plain_name(attr)
        attr.namespace&.prefix == "xml" ? "xml:#{attr.name}" : attr.name
      end

      # An entity reference (`&nbsp;`) stays as its text: lutaml-model
      # cannot read an entity it has no declaration for. A processing
      # instruction becomes an empty text.
      def plain_node(doc, src)
        case src
        when Moxml::Element then plain_element(doc, src)
        when Moxml::Cdata then doc.create_cdata(src.content)
        when Moxml::Text then doc.create_text(src.content)
        when Moxml::Comment then doc.create_comment(src.content)
        when Moxml::EntityReference then doc.create_text("&#{src.name};")
        else doc.create_text("")
        end
      end
    end
  end
end
