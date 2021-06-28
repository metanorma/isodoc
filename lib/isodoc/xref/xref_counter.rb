require "roman-numerals"

module IsoDoc
  module XrefGen
    class Counter
      def initialize(num = 0, opts = { numerals: :arabic })
        @num = num
        @letter = ""
        @subseq = ""
        @letter_override = nil
        @number_override = nil
        @style = opts[:numerals]
        @skip_i = opts[:skip_i]
        @base = ""
        if num.is_a? String
          if /^\d+$/.match?(num)
            @num = num.to_i
          else
            @num = nil
            @base = num[0..-2]
            @letter = num[-1]
          end
        end
      end

      def new_subseq_increment(node)
        @subseq = node["subsequence"]
        @num += 1 unless @num.nil?
        @letter = node["subsequence"] ? "a" : ""
        @base = ""
        new_subseq_increment1(node) if node["number"]
      end

      def new_subseq_increment1(node)
        /^(?<b>.*?)(?<n>\d*)(?<a>[a-zA-Z]*)$/ =~ node["number"]
        if !n.empty? || !a.empty?
          @letter_override = @letter = a unless a.empty?
          @number_override = @num = n.to_i unless n.empty?
          @base = b
        else
          @letter_override = node["number"]
          @letter = @letter_override if /^[a-zA-Z]$/.match?(@letter_override)
        end
      end

      def sequence_increment(node)
        if node["number"]
          @base = @letter_override = @number_override = ""
          /^(?<b>.*?)(?<n>\d+)$/ =~ node["number"]
          if blank?(n)
            @num = nil
            @base = node["number"][0..-2]
            @letter = @letter_override = node["number"][-1]
          else
            @number_override = @num = n.to_i
            @base = b
            @letter = ""
          end
        else @num += 1
        end
      end

      def subsequence_increment(node)
        return increment_letter unless node["number"]

        @base = ""
        @letter_override = node["number"]
        /^(?<b>.*?)(?<n>\d*)(?<a>[a-zA-Z])$/ =~ node["number"]
        if blank?(a) then subsequence_increment_no_letter(node)
        else
          @letter_override = @letter = a
          @base = b
          @number_override = @num = n.to_i unless n.empty?
        end
      end

      def subsequence_increment_no_letter(node)
        if /^\d+$/.match?(node["number"])
          @letter_override = @letter = ""
          @number_override = @num = node["number"].to_i
        else
          /^(?<b>.*)(?<a>[a-zA-Z])$/ =~ node["number"]
          unless blank?(a)
            @letter = @letter_override = a
            @base = b
          end
        end
      end

      def string_inc(str, start)
        return start if str.empty?

        str[0..-2] + (str[-1].ord + 1).chr.to_s
      end

      def increment_letter
        case @letter
        when "Z"
          @letter = "@"
          @base = string_inc(@base, "A")
        when "z"
          @letter = "`"
          @base = string_inc(@base, "a")
        end
        @letter = (@letter.ord + 1).chr.to_s
        @skip_i && %w(i I).include?(@letter) and
          @letter = (@letter.ord + 1).chr.to_s
      end

      def blank?(str)
        str.nil? || str.empty?
      end

      def increment(node)
        return self if node["unnumbered"]

        @letter_override = nil
        @number_override = nil
        if node["subsequence"] != @subseq &&
            !(blank?(node["subsequence"]) && blank?(@subseq))
          new_subseq_increment(node)
        elsif @letter.empty? then sequence_increment(node)
        else subsequence_increment(node)
        end
        self
      end

      def print
        num = @number_override || @num
        out = @style == :roman && !num.nil? ? RomanNumerals.to_roman(num) : num
        "#{@base}#{out}#{@letter_override || @letter}"
      end

      def ol_type(list, depth)
        return list["type"].to_sym if list["type"]
        return :arabic if [2, 7].include? depth
        return :alphabet if [1, 6].include? depth
        return :alphabet_upper if [4, 9].include? depth
        return :roman if [3, 8].include? depth
        return :roman_upper if [5, 10].include? depth

        :arabic
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
end
