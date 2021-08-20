require "twitter_cldr"
require "bigdecimal"
require "mathml2asciimath"

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
      end
    end

    # By itself twitter-cldr does not support fraction part digits grouping
    # and custom delimeter, will decorate fraction part manually
    def localized_number(num, locale, precision)
      localized = localized_number1(num, locale, precision)
      twitter_cldr_reader_symbols = twitter_cldr_reader(locale)
      return localized unless twitter_cldr_reader_symbols[:decimal]

      integer, fraction = localized.split(twitter_cldr_reader_symbols[:decimal])
      return localized if fraction.nil? || fraction.length.zero?

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
      num = TwitterCldr::DataReaders::NumberDataReader.new(locale)
      num.symbols.merge!(twitter_cldr_localiser_symbols)
    end

    def twitter_cldr_localiser
      locale = TwitterCldr.supported_locale?(@lang.to_sym) ? @lang.to_sym : :en
      twitter_cldr_reader(locale)
      locale
    end

    def asciimath_dup(node)
      a = MathML2AsciiMath.m2a(node.to_xml)
      node.next = "<!-- #{a} -->"
    end

    def mathml1(node, locale)
      asciimath_dup(node)
      localize_maths(node, locale)
      return unless node.elements.size == 1 && node.elements.first.name == "mn"

      if node.parent.name == "stem"
        node.parent.replace(node.at("./m:mn", MATHML).children)
      else
        node.replace(node.at("./m:mn", MATHML).children)
      end
    end
  end
end
