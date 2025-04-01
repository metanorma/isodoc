require "roman-numerals"
require "twitter_cldr"
require_relative "ol_type_provider"

module IsoDoc
  module XrefGen
    class ReqCounter
      # one counter for each requirements label
      def initialize
        @counters = {}
      end

      def increment(label, node)
        @counters[label] ||= Counter.new
        @counters[label].increment(node)
      end
    end

    class Counter
      include OlTypeProvider
      attr_accessor :prefix_override

      def initialize(num = 0, opts = { numerals: :arabic })
        @unnumbered = false
        @num = num
        @letter = ""
        @subseq = ""
        reset_overrides
        @style = opts[:numerals]
        @skip_i = opts[:skip_i]
        @prefix = opts[:prefix]
        @separator = opts[:separator] || "."
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

      def reset_overrides
        @letter_override = nil
        @number_override = nil
        @prefix_override = nil
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
        if node["branch-number"]
          @prefix_override = node["branch-number"]
        elsif node["number"]
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
        clock_letter
        @letter = (@letter.ord + 1).chr.to_s
        @skip_i && %w(i I).include?(@letter) and
          @letter = (@letter.ord + 1).chr.to_s
      end

      def clock_letter
        case @letter
        when "Z"
          @letter = "@"
          @base = string_inc(@base, "A")
        when "z"
          @letter = "`"
          @base = string_inc(@base, "a")
        end
      end

      def blank?(str)
        str.nil? || str.empty?
      end

      def increment(node)
        @unnumbered = node["unnumbered"] == "true" ||
          node["hidden"] == "true" and return self
        reset_overrides
        if node["subsequence"] != @subseq &&
            !(blank?(node["subsequence"]) && blank?(@subseq))
          new_subseq_increment(node)
        elsif @letter.empty? then sequence_increment(node)
        else subsequence_increment(node)
        end
        self
      end

      def style_number(num)
        num.nil? and return num
        case @style
        when :roman then RomanNumerals.to_roman(num)
        when :japanese then num.localize(:ja).spellout
        else num
        end
      end

      def print
        @unnumbered and return nil
        @prefix_override and return @prefix_override
        num = @number_override || @num
        out = style_number(num)
        prefix = @prefix
        prefix &&= "#{prefix}#{@separator}"
        "#{prefix}#{@base}#{out}#{@letter_override || @letter}"
      end

      def listlabel(list, depth)
        case ol_type(list, depth)
        when :arabic then @num.to_s
        when :alphabet then (96 + @num).chr.to_s
        when :alphabet_upper then (64 + @num).chr.to_s
        when :roman then RomanNumerals.to_roman(@num).downcase
        when :roman_upper then RomanNumerals.to_roman(@num).upcase
        when :japanese then num.localize(:ja).spellout
        end
      end
    end
  end
end
