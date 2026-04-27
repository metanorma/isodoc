require "twitter_cldr"
require "bigdecimal"
require "plurimath"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    MATHML = { "m" => "http://www.w3.org/1998/Math/MathML" }.freeze

    def mathml(docxml)
      docxml.xpath(ns("//stem")).each { |s| stem_dup(s) }
      locale = @lang.to_sym
      @numfmt = Plurimath::NumberFormatter
        .new(locale, localize_number: @localizenumber,
                     localizer_symbols: twitter_cldr_localiser_symbols)
      docxml.xpath("//m:math", MATHML).each do |f| # rubocop:disable Style/CombinableLoops
        f.parent&.parent&.name == "fmt-stem" or next
        mathml1(f, locale)
      end
    end

    # symbols is merged into
    # TwitterCldr::DataReaders::NumberDataReader.new(locale).symbols
    def localize_maths(node, locale)
      node.xpath(".//m:mn", MATHML).each do |x|
        fmt = x["data-metanorma-numberformat"]
        x.delete("data-metanorma-numberformat")
        x.children =
          if !fmt.nil? && !fmt.empty?
            explicit_number_formatter(x, locale, fmt)
          else implicit_number_formatter(x, locale)
          end
      rescue ArgumentError
      rescue StandardError, RuntimeError => e
        warn "Failure to localise MathML/mn\n#{node.parent.to_xml}\n#{e}"
      end
    end

    def normalise_number(num)
      n = BigDecimal(num).to_s("F")
      /\.\d/.match?(num) or n.sub!(/\.\d+$/, "")
      n
    end

    def implicit_number_formatter(num, locale)
      num.ancestors("formula").empty? or return
      ## by default, no formatting in formulas
      fmt = { significant: num_totaldigits(num.text, 10) }.compact
      n = normalise_number(num.text)
      @numfmt.localized_number(n, locale:, format: fmt,
                                  precision: num_precision(num.text))
    end

    def numberformat_type(ret)
      %i(precision significant digit_count group_digits fraction_group_digits
         base)
        .each do |i|
        ret[i] &&= ret[i].to_i
      end
      %i(notation exponent_sign number_sign locale hex_capital).each do |i|
        ret[i] &&= ret[i].to_sym
      end
      %i(base_prefix base_suffix).each do |i|
        ["", "nil"].include?(ret[i]) and ret[i] = nil
      end
      ret
    end

    def explicit_number_formatter(num, locale, options)
      ret = numberformat_type(csv_attribute_extract(options))
      l = ret[:locale] || locale
      precision, symbols, significant = explicit_number_formatter_cfg(num, ret)
      n = normalise_number(num.text)
      Plurimath::NumberFormatter.new(l)
        .localized_number(n, precision:,
                             format: symbols.merge(significant:))
    end

    def explicit_number_formatter_cfg(num, fmt)
      symbols = twitter_cldr_localiser_symbols.dup.transform_values do |v|
        v.is_a?(String) ? HTMLEntities.new.decode(v) : v
      end.merge(fmt)
      symbols = large_notation_fmt(symbols, num.text)
      significant = explicit_number_formatter_signif(num, symbols)
      precision = symbols[:precision] || num_precision(num.text) ||
        num_precision_from_significant(num.text, significant,
                                       (symbols[:base] || 10).to_i)
      [precision, symbols, significant]
    end

    def explicit_number_formatter_signif(num, symbols)
      signif = symbols[:significant]
      (symbols.keys & %i(precision digit_count)).empty? and
        signif ||= num_totaldigits(num.text, (symbols[:base] || 10).to_i)
      signif
    end

    def large_notation_fmt(symbols, num)
      n = symbols[:large_notation]
      min = BigDecimal(symbols[:large_notation_min] || "1e-6")
      max = BigDecimal(symbols[:large_notation_max] || "1e6")
      n1 = large_notation_fmt1(num, n, min, max) and symbols[:notation] = n1
      symbols.delete(:large_notation)
      symbols.delete(:large_notation_min)
      symbols.delete(:large_notation_max)
      symbols
    end

    def large_notation_fmt1(num, notation, min, max)
      notation.nil? || notation == "nil" and return nil
      val = BigDecimal(num).abs
      val.zero? and return nil
      val < min and return notation
      val > max and return notation
      nil
    end

    def num_precision(num)
      precision = nil
      /\.(?!\d+e)/.match?(num) and
        precision = twitter_cldr_localiser_symbols[:precision] ||
          # [^.]* excludes the delimiter itself, preventing polynomial
          # backtracking on strings with multiple dots.
          num.sub(/\A[^.]*\./, "").size
      precision
    end

    def num_totaldigits(num, base = 10)
      totaldigits = nil
      /\.(?=\d+e)/.match?(num) and
        totaldigits = twitter_cldr_localiser_symbols[:significant] ||
          num_totaldigits_compute(num, base)
      totaldigits
    end

    # In base 10, total significant digits = source mantissa length.
    # In other bases, the converted value may have fewer digits. Per
    # https://github.com/metanorma/isodoc/issues/788: if the source has
    # no fractional part after E-notation expansion, return the
    # length of the integer in the target base (e.g. 123 -> 7B = 2
    # digits, not 3); if the source has a fractional part, preserve
    # the source mantissa length so Plurimath pads the converted
    # fraction (e.g. 123.25 -> 7B.400, 123.0 -> 7B.00).
    def num_totaldigits_compute(num, base)
      # [^.]* and [^e]* exclude their respective delimiters,
      # preventing polynomial backtracking.
      mantissa = num.sub(/\A0\./, ".").sub(/\A[^.]*\./, "")
        .sub(/e[^e]*\z/, "")
      return mantissa.size if base == 10

      m = num.match(/\A-?0?\.(\d+)e(-?\d+)\z/)
      if m && m[1].length <= m[2].to_i
        BigDecimal(num).to_i.abs.to_s(base).length
      else
        mantissa.size
      end
    end

    # When base != 10 and the source is in E-notation, derive the
    # target-base fractional digit count from the total significant
    # digit count we computed. Plurimath's default precision_from()
    # returns the decimal fractional digit count, which
    # Numbers::Fraction#change_base then uses as the target-base
    # fractional digit count -- producing too few fractional digits
    # in non-decimal bases. Workaround pending upstream fix; see
    # https://github.com/metanorma/isodoc/issues/788.
    def num_precision_from_significant(num, significant, base)
      base == 10 and return nil
      significant.nil? and return nil
      /\.(?=\d+e)/.match?(num) or return nil
      m = num.match(/\A-?0?\.(\d+)e(-?\d+)\z/) or return nil
      m[1].length <= m[2].to_i and return 0
      val = BigDecimal(num).abs
      integer_len = val.to_i.zero? ? 0 : val.to_i.to_s(base).length
      [significant - integer_len, 0].max
    end

    def twitter_cldr_localiser_symbols
      {}
    end

    def asciimath_dup(node)
      @suppressasciimathdup || node.parent.at(ns("./asciimath")) and return
      math = node.to_xml.gsub(/ xmlns=["'][^"']*["']/, "")
        .gsub(%r{<[^:/>]*:}, "<").gsub(%r{</[^:/>]*:}, "</")
        .gsub(%r{ data-metanorma-numberformat="[^"]*"}, "")
      ret = Plurimath::Math.parse(math, "mathml").to_asciimath
      node.next = "<asciimath>#{@c.encode(ret, :basic)}</asciimath>"
    rescue StandardError => e
      warn "Failure to convert MathML to AsciiMath\n#{node.parent.to_xml}\n#{e}"
    end

    def maths_just_numeral(node)
      mn = node.at(".//m:mn", MATHML).children.text
        .sub(/\^([0-9+-]+)$/, "<sup>\\1</sup>")
      node.replace(mn)
    end

    def mathml1(node, locale)
      mathml_style_inherit(node)
      mathml_number(node, locale)
    end

    def stem_dup(node)
      sem_xml_descendant?(node) and return
      ret = semx_fmt_dup(node)
      f = Nokogiri::XML::Node.new("fmt-stem", node.document)
      t = node["type"] and f["type"] = t
      f << ret
      node.next = f
    end

    # convert any Ascii superscripts to correct(ish) MathML
    # Not bothering to match times, base of 1.0 x 10^-20, just ^-20
    def mn_to_msup(node)
      node.xpath(".//m:mn", MATHML).each do |n|
        m = %r{^(.+)\^([0-9+-]+)$}.match(n.text) or next
        n.replace("<msup><mn>#{m[1]}</mn><mn>#{m[2]}</mn></msup>")
      end
    end

    def mathml_number(node, locale)
      justnumeral = numeric_mathml?(node)
      justnumeral or asciimath_dup(node)
      localize_maths(node, locale)
      if justnumeral
        maths_just_numeral(node)
      else
        mn_to_msup(node)
      end
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
      node.replace(repl)
    end
  end
end
