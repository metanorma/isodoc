module Enumerable
  def noblank
    reject do |n|
      n["id"].nil? || n["id"].empty?
    end
  end
end

class Object
  def blank?
    nil? || empty?
  end
end

module IsoDoc
  module XrefGen
    module Util
      def blank?(text)
        text.nil? || text.empty?
      end

      def noblank(xpath)
        xpath.reject { |n| blank?(n["id"]) }
      end

      SECTIONS_XPATH =
        "//foreword | //introduction | //acknowledgements | " \
        "//preface/abstract | " \
        "//preface/terms | //preface/definitions | //preface/references | " \
        "//preface/clause | //sections/terms | //annex | " \
        "//sections/clause | //sections/definitions | " \
        "//bibliography/references | //bibliography/clause".freeze

      def sections_xpath
        SECTIONS_XPATH
      end

      def child_asset_path(asset)
        "./*[not(self::xmlns:clause) and not(self::xmlns:appendix) and " \
        "not(self::xmlns:terms) and not(self::xmlns:definitions)]//xmlns:X | " \
        "./xmlns:X".gsub("X", asset)
      end

      CHILD_SECTIONS = "./clause | ./appendix | ./terms | ./definitions | " \
                 "./references".freeze

      def child_sections
        CHILD_SECTIONS
      end

      # if hierarchically marked up node in label already,
      # leave alone, else wrap in semx
      def semx(node, label, element = "autonum")
        label = label.to_s
        id = node["id"] || node[:id]
        /<semx element='[^']+' source='#{id}'/.match?(label) and return label
        l = stripsemx(label)
        %(<semx element='#{element}' source='#{id}'>#{l}</semx>)
      end

      # assume parent is already semantically annotated with semx
      def hiersemx(parent, parentlabel, counter, element, sep: nil)
        sep ||= hier_separator(markup: true)
        "#{semx(parent, parentlabel)}#{sep}#{semx(element, counter.print)}"
      end

      def stripsemx(elem)
        elem.nil? and return elem
        xml = Nokogiri::XML::DocumentFragment.parse(elem)
        xml.traverse do |x|
          x.name == "semx" ||
            (x.name == "span" && /^fmt-/.match?(x["class"])) and
            x.replace(x.children)
        end
        xml.to_xml(indent: 0, encoding: "UTF-8",
                   save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
      end
    end
  end
end
