require "roman-numerals"

module IsoDoc::XrefGen
  class Counter
    def initialize
      @num = 0
      @letter = ""
      @subseq = ""
      @letter_override = nil
      @number_override = nil
    end

    def new_subseq_increment(node)
      @subseq = node["subsequence"]
      @num += 1
      @letter = node["subsequence"] ? "a" : ""
      if node["number"]
        /^(?<n>\d*)(?<a>[a-z]*)$/ =~ node["number"]
        if n || a
          @letter_override = @letter = a if a
          @number_override = @num = n.to_i if n
        else
          @letter_override = node["number"]
          @letter = @letter_override if /^[a-z]$/.match(@letter_override)
        end
      end
    end

    def sequence_increment(node)
      if node["number"]
        @number_override = node["number"]
        @num = @number_override.to_i if /^\d+$/.match(@number_override)
      else
        @num += 1
      end
    end

    def subsequence_increment(node)
      if node["number"]
        @letter_override = node["number"]
        @letter = @letter_override if /^[a-z]$/.match(@letter_override)
      else
        @letter = (@letter.ord + 1).chr.to_s
      end
    end

    def increment(node)
      return self if node["unnumbered"]
      @letter_override = nil
      @number_override = nil
      if node["subsequence"] != @subseq
        new_subseq_increment(node)
      elsif @letter.empty?
        sequence_increment(node)
      else
        subsequence_increment(node)
      end
      self
    end

    def print
      "#{@number_override || @num}#{@letter_override || @letter}"
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
