require "roman-numerals"

module IsoDoc::Function
  module XrefGen
    class Counter
      def initialize
        @num = 0
        @letter = ""
        @subseq = ""
      end

      def increment(node)
        return self if node["unnumbered"]
        if node["subsequence"] != @subseq
          @subseq = node["subsequence"]
          @num += 1
          @letter = node["subsequence"] ? "a" : ""
        else
          if @letter.empty?
            @num += 1
          else
            @letter = (@letter.ord + 1).chr.to_s
          end
        end
        self
      end

      def print
        "#{@num}#{@letter}"
      end

      def listlabel(depth)
      return @num.to_s if [2, 7].include? depth
      return (96 + @num).chr.to_s if [1, 6].include? depth
      return (64 + @num).chr.to_s if [4, 9].include? depth
      return RomanNumerals.to_roman(@num).downcase if [3, 8].include? depth
      return RomanNumerals.to_roman(@num).upcase if [5, 10].include? depth
      return @num.to_s
    end
    end
  end
end
