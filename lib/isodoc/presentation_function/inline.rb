require "twitter_cldr"
require "bigdecimal"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def prefix_container(container, linkend, _target)
      l10n(@xrefs.anchor(container, :xref) + ", " + linkend)
    end

    def anchor_linkend(node, linkend)
      if node["citeas"].nil? && node["bibitemid"]
        return @xrefs.anchor(node["bibitemid"] ,:xref) || "???"
      elsif node["target"] && node["droploc"]
        return @xrefs.anchor(node["target"], :value) || @xrefs.anchor(node["target"], :label) ||
          @xrefs.anchor(node["target"], :xref) || "???"
      elsif node["target"] && !/.#./.match(node["target"])
        linkend = anchor_linkend1(node)
      end
      linkend || "???"
    end

    def anchor_linkend1(node)
      linkend = @xrefs.anchor(node["target"], :xref)
      container = @xrefs.anchor(node["target"], :container, false)
      (container && get_note_container_id(node) != container && @xrefs.get[node["target"]]) &&
        linkend = prefix_container(container, linkend, node["target"])
      capitalise_xref(node, linkend)
    end

    def capitalise_xref(node, linkend)
      return linkend unless %w(Latn Cyrl Grek).include? @script
      return linkend&.capitalize if node["case"] == "capital"
      return linkend&.downcase if node["case"] == "lowercase"
      return linkend if linkend[0,1].match(/\p{Upper}/)
      prec = nearest_block_parent(node).xpath("./descendant-or-self::text()") &
        node.xpath("./preceding::text()")
      (prec.empty? || /(?!<[^.].)\.\s+$/.match(prec.map { |p| p.text }.join)) ?  linkend&.capitalize : linkend
    end

    def nearest_block_parent(node)
      until %w(p title td th name formula li dt dd sourcecode pre).include?(node.name)
        node = node.parent
      end
      node
    end

    def non_locality_elems(node)
      node.children.select do |c|
        !%w{locality localityStack}.include? c.name
      end
    end

    def get_linkend(node)
      contents = non_locality_elems(node).select { |c| !c.text? || /\S/.match(c) }
      return unless contents.empty?
      link = anchor_linkend(node, docid_l10n(node["target"] || node["citeas"]))
      link += eref_localities(node.xpath(ns("./locality | ./localityStack")), link, node)
      non_locality_elems(node).each { |n| n.remove }
      node.add_child(link)
    end
    # so not <origin bibitemid="ISO7301" citeas="ISO 7301">
    # <locality type="section"><reference>3.1</reference></locality></origin>

    def eref_localities(refs, target, n)
      ret = ""
      refs.each_with_index do |r, i|
        delim = ","
        delim = ";" if r.name == "localityStack" && i>0
        ret = eref_locality_stack(r, i, target, delim, ret, n)
      end
      ret
    end

    def eref_locality_stack(r, i, target, delim, ret, n)
      if r.name == "localityStack"
        r.elements.each_with_index do |rr, j|
          ret += eref_localities0(rr, j, target, delim, n)
          delim = ","
        end
      else
        ret += eref_localities0(r, i, target, delim, n)
      end
      ret
    end

    def eref_localities0(r, i, target, delim, n)
      if r["type"] == "whole" then l10n("#{delim} #{@i18n.wholeoftext}")
      else
        eref_localities1(target, r["type"], r.at(ns("./referenceFrom")),
                         r.at(ns("./referenceTo")), delim, n, @lang)
      end
    end

    # TODO: move to localization file
    def eref_localities1_zh(target, type, from, to, n, delim)
      ret = "#{delim} 第#{from.text}" if from
      ret += "&ndash;#{to.text}" if to
      loc = (@i18n.locality[type] || type.sub(/^locality:/, "").capitalize )
      ret += " #{loc}" unless n["droploc"] == "true"
      ret
    end

    # TODO: move to localization file
    def eref_localities1(target, type, from, to, delim, n, lang = "en")
      return "" if type == "anchor"
      lang == "zh" and return l10n(eref_localities1_zh(target, type, from, to, n, delim))
      ret = delim
      ret += eref_locality_populate(type, n)
      ret += " #{from.text}" if from
      ret += "&ndash;#{to.text}" if to
      l10n(ret)
    end

    def eref_locality_populate(type, n)
      return "" if n["droploc"] == "true"
      loc = @i18n.locality[type] || type.sub(/^locality:/, "")
      loc = case n["case"]
            when "capital" then loc.capitalize
            when "lowercase" then loc.downcase
            else
              loc.capitalize
            end
      " #{loc}"
    end

    def xref(docxml)
      docxml.xpath(ns("//xref")).each { |f| xref1(f) }
    end

    def eref(docxml)
      docxml.xpath(ns("//eref")).each { |f| xref1(f) }
    end

    def origin(docxml)
      docxml.xpath(ns("//origin[not(termref)]")).each { |f| xref1(f) }
    end

    def quotesource(docxml)
      docxml.xpath(ns("//quote/source")).each { |f| xref1(f) }
    end

    def xref1(f)
      get_linkend(f)
    end

    def concept(docxml)
      docxml.xpath(ns("//concept")).each { |f| concept1(f) }
    end

    def concept1(node)
      content = node.first_element_child.children.select do |c|
        !%w{locality localityStack}.include? c.name
      end.select { |c| !c.text? || /\S/.match(c) }
      node.replace content.empty? ? 
        @i18n.term_defined_in.sub(/%/, node.first_element_child.to_xml) :
        "<em>#{node.children.to_xml}</em>"
    end


    MATHML = { "m" => "http://www.w3.org/1998/Math/MathML" }.freeze

    def mathml(docxml)
      locale = twitter_cldr_localiser()
      docxml.xpath("//m:math", MATHML).each do |f|
        mathml1(f, locale)
      end
    end

    # symbols is merged into
    # TwitterCldr::DataReaders::NumberDataReader.new(locale).symbols
    def localize_maths(f, locale)
      f.xpath(".//m:mn", MATHML).each do |x|
        num = BigDecimal(x.text)
        precision = /\./.match(x.text) ? x.text.sub(/^.*\./, "").size : 0
        x.children = localized_number(num, locale, precision)
      end
    end

    # By itself twitter-cldr does not support fraction part digits grouping
    # and custom delimeter, will decorate fraction part manually
    def localized_number(num, locale, precision)
      localized = (precision == 0) ? num.localize(locale).to_s :
        num.localize(locale).to_decimal.to_s(:precision => precision)
      twitter_cldr_reader_symbols = twitter_cldr_reader(locale)
      return localized unless twitter_cldr_reader_symbols[:decimal]
      integer, fraction = localized.split(twitter_cldr_reader_symbols[:decimal])
      return localized if fraction.nil? || fraction.length.zero?
      [integer, decorate_fraction_part(fraction, locale)].join(twitter_cldr_reader_symbols[:decimal])
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

    def twitter_cldr_localiser()
      locale = TwitterCldr.supported_locale?(@lang.to_sym) ? @lang.to_sym : :en
      twitter_cldr_reader(locale)
      locale
    end

    def mathml1(f, locale)
      localize_maths(f, locale)
      return unless f.elements.size == 1 && f.elements.first.name == "mn"
      if f.parent.name == "stem"
        f.parent.replace(f.at("./m:mn", MATHML).children)
      else
        f.replace(f.at("./m:mn", MATHML).children)
      end
    end

    def variant(docxml)
      docxml.xpath(ns("//variant")).each { |f| variant1(f) }
      docxml.xpath(ns("//variant[@remove = 'true']")).each { |f| f.remove }
      docxml.xpath(ns("//variant")).each do |v|
        next unless v&.next&.name == "variant"
        v.next = "/"
      end
      docxml.xpath(ns("//variant")).each { |f| f.replace(f.children) }
    end

    def variant1(node)
      if (!node["lang"] || node["lang"] == @lang) && (!node["script"] || node["script"] == @script)
      elsif found_matching_variant_sibling(node)
        node["remove"] = "true"
      else
        #return unless !node.at("./preceding-sibling::xmlns:variant")
      end
    end

    private

    def found_matching_variant_sibling(node)
      prev = node.xpath("./preceding-sibling::xmlns:variant")
      foll = node.xpath("./following-sibling::xmlns:variant")
      found = false
      (prev + foll).each do |n|
        found = true if n["lang"] == @lang && (!n["script"] || n["script"] == @script)
      end
      found
    end
  end
end
