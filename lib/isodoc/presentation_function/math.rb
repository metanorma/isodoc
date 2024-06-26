require "twitter_cldr"
require "bigdecimal"
require "plurimath"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    MATHML = { "m" => "http://www.w3.org/1998/Math/MathML" }.freeze

    def mathml(docxml)
      docxml.xpath("//m:math", MATHML).each { |f| mathml_linebreak(f) }
      locale = @lang.to_sym
      @numfmt = Plurimath::NumberFormatter
        .new(locale, localize_number: @localizenumber,
                     localizer_symbols: twitter_cldr_localiser_symbols)
      docxml.xpath("//m:math", MATHML).each do |f| # rubocop:disable Style/CombinableLoops
        mathml1(f, locale)
      end
    end

    # symbols is merged into
    # TwitterCldr::DataReaders::NumberDataReader.new(locale).symbols
    def localize_maths(node, locale)
      node.xpath(".//m:mn", MATHML).each do |x|
        x.children =
          if fmt = x["data-metanorma-numberformat"]
            x.delete("data-metanorma-numberformat")
            explicit_number_formatter(x, locale, fmt)
          else implicit_number_formatter(x, locale)
          end
      rescue ArgumentError
      rescue Error => e
        warn "Failure to localised MathML/mn\n#{node.parent.to_xml}\n#{e}"
      end
    end

    def normalise_number(num)
      n = BigDecimal(num).to_s("F")
      /\.\d/.match?(num) or n.sub!(/\.\d+$/, "")
      n
    end

    def implicit_number_formatter(num, locale)
      fmt = { digit_count: num_totaldigits(num.text) }.compact
      n = normalise_number(num.text)
      # Plurimath confused by exponent notation
      #warn "IMPLICIT: precision: #{num_precision(num.text)} ; symbols: #{fmt}, n: #{n}; output: #{@numfmt.localized_number(n, locale:, format: fmt, precision: num_precision(num.text))}"
      @numfmt.localized_number(n, locale:, format: fmt,
                                  precision: num_precision(num.text))
    end

    def numberformat_extract(options)
      options.gsub!(/([a-z_]+)='/, %('\\1=))
      CSV.parse_line(options, quote_char: "'").each_with_object({}) do |x, acc|
        m = /^(.+?)=(.+)?$/.match(x) or next
        acc[m[1].to_sym] = m[2].sub(/^(["'])(.+)\1$/, "\\2")
      end
    end

    def numberformat_type(ret)
      %i(precision digit_count group_digits fraction_group_digits).each do |i|
        ret[i] &&= ret[i].to_i
      end
      %i(notation exponent_sign locale).each do |i|
        ret[i] &&= ret[i].to_sym
      end
      ret
    end

    def explicit_number_formatter(num, locale, options)
      ret = numberformat_type(numberformat_extract(options))
      l = ret[:locale] || locale
      precision, symbols, digit_count = explicit_number_formatter_cfg(num, ret)
      n = normalise_number(num.text)
      # Plurimath confused by exponent notation
      #warn "EXPLICIT: precision: #{precision} ; symbols: #{symbols}, n: #{n}; output: #{Plurimath::NumberFormatter.new(l, localizer_symbols: symbols).localized_number(n, precision:, format: symbols.merge(digit_count:))}"
      Plurimath::NumberFormatter.new(l, localizer_symbols: symbols)
        .localized_number(n, precision:,
                             format: symbols.merge(digit_count:))
    end

    def explicit_number_formatter_cfg(num, fmt)
      symbols = twitter_cldr_localiser_symbols.dup.merge(fmt)
      precision = symbols[:precision]&.to_i || num_precision(num.text)
      symbols[:precision] or digit_count = num_totaldigits(num.text)
      [precision, symbols, digit_count]
    end

    def num_precision(num)
      precision = nil
      /\.(?!\d+e)/.match?(num) and
        precision = twitter_cldr_localiser_symbols[:precision] ||
          num.sub(/^.*\./, "").size
      precision
    end

    def num_totaldigits(num)
      totaldigits = nil
      /\.(?=\d+e)/.match?(num) and
        totaldigits = twitter_cldr_localiser_symbols[:digit_count] ||
          num.sub(/^.*\./, "").sub(/e.*$/, "").size
      totaldigits
    end

    def twitter_cldr_localiser_symbols
      {}
    end

    def asciimath_dup(node)
      @suppressasciimathdup || node.parent.at(ns("./asciimath")) and return
      math = node.to_xml.gsub(/ xmlns=["'][^"']+["']/, "")
        .gsub(%r{<[^:/>]+:}, "<").gsub(%r{</[^:/>]+:}, "</")
      ret = Plurimath::Math.parse(math, "mathml").to_asciimath
      node.next = "<asciimath>#{@c.encode(ret, :basic)}</asciimath>"
    rescue StandardError => e
      warn "Failure to convert MathML to AsciiMath\n#{node.parent.to_xml}\n#{e}"
    end

    def maths_just_numeral(node)
      mn = node.at(".//m:mn", MATHML).children
      if node.parent.name == "stem"
        node.parent.replace(mn)
      else
        node.replace(mn)
      end
    end

    def mathml1(node, locale)
      mathml_style_inherit(node)
      mathml_number(node, locale)
    end

    def mathml_linebreak(node)
      node.at(".//*/@linebreak") or return
      m = Plurimath::Math.parse(node.to_xml, :mathml)
        .to_mathml(split_on_linebreak: true)
      ret = Nokogiri::XML("<m>#{m}</m>").root
      ret.elements.each_with_index do |e, i|
        i.zero? or e.previous = "<br/>"
      end
      node.replace(<<~OUTPUT)
        <math-with-linebreak>#{ret.children}</math-with-linebreak><math-no-linebreak>#{node.to_xml}</math-no-linebreak>
      OUTPUT
    end

    def mathml_number(node, locale)
      justnumeral = numeric_mathml?(node)
      justnumeral or asciimath_dup(node)
      localize_maths(node, locale)
      justnumeral and maths_just_numeral(node)
    end

    def numeric_mathml?(node)
      m = {}
      node.traverse do |x|
        %w(mstyle mrow math text).include?(x.name) and next
        m[x.name] ||= 0
        m[x.name] += 1
      end
      m.keys.size == 1 && m["mn"] == 1
    end

    def mathml_style_inherit(node)
      node.at("./ancestor::xmlns:strong") or return
      node.children =
        "<mstyle mathvariant='bold'>#{node.children.to_xml}</mstyle>"
    end

    def mathml_number_to_number(node)
      (node.elements.size == 1 && node.elements.first.name == "mn") or return
      repl = node.at("./m:mn", MATHML).children
      if node.parent.name == "stem"
        node.parent.replace(repl)
      else
        node.replace(repl)
      end
    end
  end
end
