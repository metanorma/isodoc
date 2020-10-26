require "twitter_cldr"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def prefix_container(container, linkend, _target)
      l10n(@xrefs.anchor(container, :xref) + ", " + linkend)
    end

    def anchor_linkend(node, linkend)
      if node["citeas"].nil? && node["bibitemid"]
        return @xrefs.anchor(node["bibitemid"] ,:xref) || "???"
      elsif node["target"] && node["droploc"]
        return @xrefs.anchor(node["target"], :value) || 
          @xrefs.anchor(node["target"], :label) || 
          @xrefs.anchor(node["target"], :xref) || "???"
      elsif node["target"] && !/.#./.match(node["target"])
        linkend = anchor_linkend1(node)
      end
      linkend || "???"
    end

    def anchor_linkend1(node)
      linkend = @xrefs.anchor(node["target"], :xref)
      container = @xrefs.anchor(node["target"], :container, false)
      (container && get_note_container_id(node) != container &&
       @xrefs.get[node["target"]]) &&
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
      (prec.empty? || /(?!<[^.].)\.\s+$/.match(prec.map { |p| p.text }.join)) ?
        linkend&.capitalize : linkend
    end

    def nearest_block_parent(node)
      until %w(p title td th name formula 
        li dt dd sourcecode pre).include?(node.name)
        node = node.parent
      end
      node
    end

    def non_locality_elems(node)
      node.children.select do |c|
        !%w{locality localityStack}.include? c.name
      end
    end

    def get_linkend(n)
      contents = non_locality_elems(n).select { |c| !c.text? || /\S/.match(c) }
      return unless contents.empty?
      link = anchor_linkend(n, docid_l10n(n["target"] || n["citeas"]))
      link += eref_localities(n.xpath(ns("./locality | ./localityStack")), link)
      non_locality_elems(n).each { |n| n.remove }
      n.add_child(link)
    end
    # so not <origin bibitemid="ISO7301" citeas="ISO 7301">
    # <locality type="section"><reference>3.1</reference></locality></origin>

    def eref_localities(refs, target)
      ret = ""
      refs.each_with_index do |r, i|
        delim = ","
        delim = ";" if r.name == "localityStack" && i>0
        ret = eref_locality_stack(r, i, target, delim, ret)
      end
      ret
    end

    def eref_locality_stack(r, i, target, delim, ret)
      if r.name == "localityStack"
        r.elements.each_with_index do |rr, j|
          ret += eref_localities0(rr, j, target, delim)
          delim = ","
        end
      else
        ret += eref_localities0(r, i, target, delim)
      end
      ret
    end

    def eref_localities0(r, i, target, delim)
      if r["type"] == "whole" then l10n("#{delim} #{@i18n.wholeoftext}")
      else
        eref_localities1(target, r["type"], r.at(ns("./referenceFrom")),
                         r.at(ns("./referenceTo")), delim, @lang)
      end
    end

    # TODO: move to localization file
    def eref_localities1_zh(target, type, from, to, delim)
      ret = "#{delim} 第#{from.text}" if from
      ret += "&ndash;#{to.text}" if to
      loc = (@i18n.locality[type] || type.sub(/^locality:/, "").capitalize )
      ret += " #{loc}"
      ret
    end

    # TODO: move to localization file
    def eref_localities1(target, type, from, to, delim, lang = "en")
      return "" if type == "anchor"
      lang == "zh" and
        return l10n(eref_localities1_zh(target, type, from, to, delim))
      ret = delim
      loc = @i18n.locality[type] || type.sub(/^locality:/, "").capitalize
      ret += " #{loc}"
      ret += " #{from.text}" if from
      ret += "&ndash;#{to.text}" if to
      l10n(ret)
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
        num = /\./.match(x.text) ? x.text.to_f : x.text.to_i
        x.children = num.localize(locale).to_s
      end
    end

    def twitter_cldr_localiser_symbols
      {}
    end

    def twitter_cldr_localiser()
      num = TwitterCldr::DataReaders::NumberDataReader.new(@lang.to_sym)
      num.symbols.merge!(twitter_cldr_localiser_symbols)
      return @lang.to_sym
    end

    def mathml1(f, locale)
      localize_maths(f, locale)
      return unless f.elements.size == 1 && f.elements.first.name == "mn"
      f.replace(f.at("./m:mn", MATHML).children)
    end
  end
end
