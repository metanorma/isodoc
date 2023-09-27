module Enumerable
  def noblank
    reject do |n|
      n["id"].nil? || n["id"].empty?
    end
  end
end

module IsoDoc
  module XrefGen
    module Blocks
      def blank?(text)
        text.nil? || text.empty?
      end

      def noblank(xpath)
        xpath.reject { |n| blank?(n["id"]) }
      end

      SECTIONS_XPATH =
        "//foreword | //introduction | //acknowledgements | " \
        "//preface/terms | preface/definitions | preface/references | " \
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
    end
  end
end
