module ::TwitterCldr
  module Formatters
    class NumberFormatter
      def parse_number(number, options = {})
        precision = options[:precision] || precision_from(number)
        rounding = options[:rounding] || 0
        if number.is_a? BigDecimal
          number = precision == 0 ? 
            round_to(number, precision, rounding).abs.fix.to_s("F") :
            round_to(number, precision, rounding).abs.round(precision).to_s("F")
        else
          number = "%.#{precision}f" % round_to(number, precision, rounding).abs
        end
        number.split(".")
      end

      def round_to(number, precision, rounding = 0)
        factor = 10 ** precision
        result = number.is_a?(BigDecimal) ?
          ((number * factor).fix / factor) :
          ((number * factor).round.to_f / factor)
        if rounding > 0
          rounding = rounding.to_f / factor
          result = number.is_a?(BigDecimal) ?
            ((result *  (1.0 / rounding)).fix / (1.0 / rounding)) :
            ((result *  (1.0 / rounding)).round.to_f / (1.0 / rounding))
        end
        result
      end

      def precision_from(num)
        return 0 if num.is_a?(BigDecimal) && num.fix == num
        parts = (num.is_a?(BigDecimal) ? num.to_s("F") : num.to_s ).split(".")
        parts.size == 2 ? parts[1].size : 0
      end
    end
  end
end

