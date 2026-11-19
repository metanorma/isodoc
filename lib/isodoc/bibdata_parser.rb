# frozen_string_literal: true

require "moxml"
require "relaton"
require "relaton/bib"

module IsoDoc
  # Bibdata ingestion through relaton's library surface, not Relaton::Cli.
  #
  # Same pattern as Metanorma::Collection::Config::BibdataParser
  # (metanorma/metanorma#716), which mirrors the flavor dispatch of
  # relaton cli.rb parse_xml: the processor is named by the first
  # docidentifier's type, else by the leading word of its text. It takes
  # an XML String, so it behaves the same on relaton releases before and
  # after 3.1.6, where Cli.parse_xml changed from a Nokogiri document to a
  # String argument.
  module BibdataParser
    class << self
      # @param xml [String] serialized bibdata or bibitem XML
      # @return [Relaton::Bib::ItemData, nil] nil when the source is not
      #   parseable XML
      def from_xml(xml)
        return unless xml

        doc = Moxml.new.parse(xml)
        plain = without_namespaces(doc)
        processor = processor_for_xml(doc)
        processor ? processor.from_xml(plain) : generic_from_xml(plain)
      rescue Moxml::ParseError
        nil
      end

      private

      # No-flavor fallback: unparseable sources degrade to a nil bibdata,
      # as in the mirrored Cli method.
      def generic_from_xml(plain)
        Relaton::Bib::Item.from_xml(plain)
      rescue StandardError
        nil
      end

      # The processor named by the first docidentifier's type, else by
      # the first word of its text.
      def processor_for_xml(doc)
        docid = doc.xpath("//*[local-name()='docidentifier']").first
        return unless docid

        get_proc(docid) ||
          Relaton::Db::Registry.instance.by_type(docid.text[/^\w+/])
      end

      def get_proc(docid)
        type = docid["type"]
        return unless type

        Relaton::Db::Registry.instance.by_type(type)
      end

      # The root element as XML, with every element and attribute in no
      # namespace (`xml:` attributes keep their prefix). The lutaml-model
      # mappings are namespace-free, and Moxml cannot drop a namespace in
      # place, so this builds a copy.
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
