require "twitter_cldr"
require "bigdecimal"
require "plurimath"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    MATHML = { "m" => "http://www.w3.org/1998/Math/MathML" }.freeze

    def mathml(docxml)
      locale = twitter_cldr_localiser
      docxml.xpath("//m:math", MATHML).each do |f|
        mathml1(f, locale)
      end
    end

    # symbols is merged into
    # TwitterCldr::DataReaders::NumberDataReader.new(locale).symbols
    def localize_maths(node, locale)
      node.xpath(".//m:mn", MATHML).each do |x|
        num = BigDecimal(x.text)
        precision = /\./.match?(x.text) ? x.text.sub(/^.*\./, "").size : 0
        x.children = localized_number(num, locale, precision)
      rescue ArgumentError
      end
    end

    # By itself twitter-cldr does not support fraction part digits grouping
    # and custom delimeter, will decorate fraction part manually
    def localized_number(num, locale, precision)
      localized = localized_number1(num, locale, precision)
      twitter_cldr_reader_symbols = twitter_cldr_reader(locale)
      return localized unless twitter_cldr_reader_symbols[:decimal]

      integer, fraction = localized.split(twitter_cldr_reader_symbols[:decimal])
      return localized if fraction.nil? || fraction.empty?

      [integer, decorate_fraction_part(fraction, locale)]
        .join(twitter_cldr_reader_symbols[:decimal])
    end

    def localized_number1(num, locale, precision)
      if precision.zero?
        num.localize(locale).to_s
      else
        num.localize(locale).to_decimal.to_s(precision: precision)
      end
    end

    def decorate_fraction_part(fract, locale)
      result = []
      twitter_cldr_reader_symbols = twitter_cldr_reader(locale)
      fract = fract.slice(0..(twitter_cldr_reader_symbols[:precision] || -1))
      fr_group_digits = twitter_cldr_reader_symbols[:fraction_group_digits] || 1
      until fract.empty?
        result.push(fract.slice!(0, fr_group_digits))
      end
      result.join(twitter_cldr_reader_symbols[:fraction_group].to_s)
    end

    def twitter_cldr_localiser_symbols
      {}
    end

    def twitter_cldr_reader(locale)
      return @twitter_cldr_reader if @twitter_cldr_reader

      num = TwitterCldr::DataReaders::NumberDataReader.new(locale)
      @twitter_cldr_reader = num.symbols.merge!(twitter_cldr_localiser_symbols)
        .merge!(parse_localize_number)
      @twitter_cldr_reader
    end

    def twitter_cldr_localiser
      locale = TwitterCldr.supported_locale?(@lang.to_sym) ? @lang.to_sym : :en
      twitter_cldr_reader(locale)
      locale
    end

    def parse_localize_number
      return {} unless @localizenumber

      m = %r{(?<group>[^#])?(?<groupdigits>#+0)(?<decimal>.)(?<fractdigits>#+)(?<fractgroup>[^#])?}
        .match(@localizenumber) or return {}
      ret = { decimal: m[:decimal], group_digits: m[:groupdigits].size,
              fraction_group_digits: m[:fractdigits].size,
              group: m[:group] || "",
              fraction_group: m[:fractgroup] || "" }.compact
      %i(group fraction_group).each { |x| ret[x] == " " and ret[x] = "\u00A0" }
      ret
    end

    def asciimath_dup(node)
      return if @suppressasciimathdup

      math = node.to_xml.gsub(/ xmlns=["'][^"']+["']/, "")
        .gsub(%r{<[^:/>]+:}, "<").gsub(%r{</[^:/>]+:}, "</")
      ret = Plurimath::Math.parse(math, "mathml").to_asciimath
      ret = HTMLEntities.new.encode(ret, :basic)
      node.next = "<asciimath>#{ret}</asciimath>"
    rescue StandardError => e
      warn "Failure to convert MathML to AsciiMath"
      warn node.parent.to_xml
      warn e
    end

    def maths_just_numeral(node)
      mn = node.at("./m:mn", MATHML).children
      if node.parent.name == "stem"
        node.parent.replace(mn)
      else
        node.replace(mn)
      end
    end

    def mathml1(node, locale)
      mathml_style_inherit(node)
      justnumeral = node.elements.size == 1 && node.elements.first.name == "mn"
      justnumeral or asciimath_dup(node)
      localize_maths(node, locale)
      justnumeral and maths_just_numeral(node)
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
