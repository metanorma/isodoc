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

      def hiersep
        "."
      end

      def hierfigsep
        "-"
      end

      def hierreqtsep
        "-"
      end

      def hier_separator(markup: false)
        h = hiersep
        h.blank? || !markup or h = delim_wrap(h)
        h
      end

      def subfigure_separator(markup: false)
        h = hierfigsep
        h.blank? || !markup or h = delim_wrap(h)
        h
      end

      def subreqt_separator(markup: false)
        h = hierreqtsep
        h.blank? || !markup or h = delim_wrap(h)
        h
      end

      def subfigure_delim
        ""
      end

      def nodeSet(clauses)
        case clauses
        when Nokogiri::XML::Node
          [clauses]
        when Nokogiri::XML::NodeSet
          clauses
        end
      end

      SECTIONS_XPATH =
        "//foreword | //introduction | //acknowledgements | " \
        "//executivesummary | //preface/abstract | " \
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

      SUBCLAUSES =
        "./clause | ./references | ./term  | ./terms | ./definitions".freeze

      def subclauses
        SUBCLAUSES
      end

      FIRST_LVL_REQ_RULE = <<~XPATH.freeze
        [not(ancestor::permission or ancestor::requirement or ancestor::recommendation)]
      XPATH

      FIRST_LVL_REQ = <<~XPATH.freeze
        .//permission#{FIRST_LVL_REQ_RULE} | .//requirement#{FIRST_LVL_REQ_RULE} | .//recommendation#{FIRST_LVL_REQ_RULE}
      XPATH

      def first_lvl_req
        FIRST_LVL_REQ
      end

      REQ_CHILDREN = <<~XPATH.freeze
        ./permission | ./requirement | ./recommendation
      XPATH

      def req_children
        REQ_CHILDREN
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

      def delim_wrap(delim, klass = "fmt-autonum-delim")
        delim.blank? and return ""
        "<span class='#{klass}'>#{delim}</span>"
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

      def labelled_autonum(label, autonum)
        label.blank? and return autonum
        l10n("<span class='fmt-element-name'>#{label}</span> #{autonum}")
      end

      def increment_label(elems, node, counter, increment: true)
        elems.size == 1 && !node["number"] and return ""
        counter.increment(node) if increment
        counter.print
      end
    end
  end
end
