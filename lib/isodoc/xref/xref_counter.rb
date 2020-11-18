require "roman-numerals"

module IsoDoc::XrefGen
  class Counter
    def initialize(num = 0)
      @num = num
      @letter = ""
      @subseq = ""
      @letter_override = nil
      @number_override = nil
      @base = ""
    end

    def new_subseq_increment(node)
      @subseq = node["subsequence"]
      @num += 1
      @letter = node["subsequence"] ? "a" : ""
      @base = ""
      if node["number"]
        /^(?<b>.*?)(?<n>\d*)(?<a>[a-z]*)$/ =~ node["number"]
        if !n.empty? || !a.empty?
          @letter_override = @letter = a unless a.empty?
          @number_override = @num = n.to_i unless n.empty?
          @base = b
        else
          @letter_override = node["number"]
          @letter = @letter_override if /^[a-z]$/.match(@letter_override)
        end
      end
    end

    def sequence_increment(node)
      if node["number"]
        @base = ""
        @number_override = node["number"]
        /^(?<b>.*?)(?<n>\d+)$/ =~ node["number"]
        unless n.nil? || n.empty?
          @num = n.to_i
          @base = b
        end
      else
        @num += 1
      end
    end

    def subsequence_increment(node)
      if node["number"]
        @base = ""
        @letter_override = node["number"]
        /^(?<b>.*?)(?<n>\d*)(?<a>[a-z]+)$/ =~ node["number"]
        unless a.empty?
          @letter = a
          @base = b
          @number_override = @num = n.to_i unless n.empty?
        end
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
      "#{@base}#{@number_override || @num}#{@letter_override || @letter}"
    end

    def ol_type(list, depth)
      return list["type"].to_sym if list["type"]
      return :arabic if [2, 7].include? depth
      return :alphabet if [1, 6].include? depth
      return :alphabet_upper if [4, 9].include? depth
      return :roman if [3, 8].include? depth
      return :roman_upper if [5, 10].include? depth
      return :arabic
    end

    def listlabel(list, depth)
      case ol_type(list, depth)
      when :arabic then @num.to_s
      when :alphabet then (96 + @num).chr.to_s
      when :alphabet_upper then (64 + @num).chr.to_s
      when :roman then RomanNumerals.to_roman(@num).downcase
      when :roman_upper then RomanNumerals.to_roman(@num).upcase
      end
    end
  end
end
