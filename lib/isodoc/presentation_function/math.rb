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
      fmt = { significant: num_totaldigits(num.text) }.compact
      n = normalise_number(num.text)
      @numfmt.localized_number(n, locale:, format: fmt,
                                  precision: num_precision(num.text))
    end

    COMMA_PLACEHOLDER = "##COMMA##".freeze

    # Temporarily replace commas inside quotes with a placeholder
    def comma_placeholder(options)
      processed = ""
      in_quotes = false
      options.each_char do |c|
        c == "'" and in_quotes = !in_quotes
        processed << if c == "," && in_quotes
                       COMMA_PLACEHOLDER
                     else c end
      end
      processed
    end

    def numberformat_extract(options)
      options.gsub!(/([a-z_]+)='/, %('\\1=))
      processed = comma_placeholder(options)
      CSV.parse_line(processed,
                     quote_char: "'").each_with_object({}) do |x, acc|
        x.gsub!(COMMA_PLACEHOLDER, ",")
        m = /^(.+?)=(.+)?$/.match(x) or next
        acc[m[1].to_sym] = m[2].sub(/^(["'])(.+)\1$/, "\\2")
      end
    end

    def numberformat_type(ret)
      %i(precision significant digit_count group_digits fraction_group_digits)
        .each do |i|
          ret[i] &&= ret[i].to_i
        end
      %i(notation exponent_sign number_sign locale).each do |i|
        ret[i] &&= ret[i].to_sym
      end
      ret
    end

    def explicit_number_formatter(num, locale, options)
      ret = numberformat_type(numberformat_extract(options))
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
      [symbols[:precision] || num_precision(num.text), symbols,
       explicit_number_formatter_signif(num, symbols)]
    end

    def explicit_number_formatter_signif(num, symbols)
      signif = symbols[:significant]
      (symbols.keys & %i(precision digit_count)).empty? and
        signif ||= num_totaldigits(num.text)
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
          num.sub(/^.*\./, "").size
      precision
    end

    def num_totaldigits(num)
      totaldigits = nil
      /\.(?=\d+e)/.match?(num) and
        totaldigits = twitter_cldr_localiser_symbols[:significant] ||
          num.sub(/^0\./, ".").sub(/^.*\./, "").sub(/e.*$/, "").size
      totaldigits
    end

    def twitter_cldr_localiser_symbols
      {}
    end

    def asciimath_dup(node)
      @suppressasciimathdup || node.parent.at(ns("./asciimath")) and return
      math = node.to_xml.gsub(/ xmlns=["'][^"']+["']/, "")
        .gsub(%r{<[^:/>]+:}, "<").gsub(%r{</[^:/>]+:}, "</")
        .gsub(%r{ data-metanorma-numberformat="[^"]+"}, "")
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
