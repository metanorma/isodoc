module IsoDoc
  module HtmlFunction
    # Class for recursively converting mathvariant text into plain text symbols
    class MathvariantToPlain
      MATHML = { "m" => "http://www.w3.org/1998/Math/MathML" }.freeze
      MATHVARIANT_SPECIAL_CASE_MAPPINGS_1 = %w[bold italic sans-serif]
        .permutation
        .each_with_object(:sansbolditalic)
        .map { |n, y| [n, y] }
        .to_h
        .freeze
      MATHVARIANT_SPECIAL_CASE_MAPPINGS_2 = {
        %w[bold fraktur] => :frakturbold,
        %w[bold script] => :scriptbold,
        %w[sans-serif bold] => :sansbold,
        %w[sans-serif italic] => :sansitalic,
        %w[sans-serif bold-italic] => :sansbolditalic,
        %w[bold-sans-serif italic] => :sansbolditalic,
        %w[sans-serif-italic bold] => :sansbolditalic,
      }.freeze
      MATHVARIANT_TO_PLANE_MAPPINGS = {
        %w[double-struck] => :doublestruck,
        %w[bold-fraktur] => :frakturbold,
        %w[script] => :script,
        %w[bold-script] => :scriptbold,
        %w[fraktur] => :fraktur,
        %w[sans-serif] => :sans,
        %w[bold-sans-serif] => :sansbold,
        %w[sans-serif-italic] => :sansitalic,
        %w[sans-serif-bold-italic] => :sansbolditalic,
        %w[monospace] => :monospace,
      }.freeze

      attr_reader :docxml

      # @param [Nokogiri::Document] docxml
      def initialize(docxml)
        @docxml = docxml
      end

      def convert
        docxml.xpath("//m:math", MATHML).each do |elem|
          next if nothing_to_style(elem)

          mathml1(elem)
        end
        docxml
      end

      private

      def nothing_to_style(elem)
        !elem.at("./*[@mathvariant][not(@mathvariant = 'normal')]"\
                 "[not(@mathvariant = 'italic')]")
      end

      def mathml1(base_elem)
        MATHVARIANT_SPECIAL_CASE_MAPPINGS_1
          .merge(MATHVARIANT_SPECIAL_CASE_MAPPINGS_2)
          .merge(MATHVARIANT_TO_PLANE_MAPPINGS)
          .each_pair do |mathvariant_list, plain_font|
            base_elem.xpath(mathvariant_xpath(mathvariant_list)).each do |elem|
              to_plane(elem, plain_font)
            end
          end
      end

      def mathvariant_xpath(list)
        list
          .map { |variant| "//*[@mathvariant = '#{variant}']" }
          .join
      end

      def to_plane(elem, font)
        elem.traverse do |n|
          next unless n.text?

          n.replace(Plane1Converter.conv(HTMLEntities.new.decode(n.text), font))
        end
        elem
      end
    end
  end
end
