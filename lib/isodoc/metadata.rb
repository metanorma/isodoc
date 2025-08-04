require_relative "metadata_date"
require_relative "metadata_contributor"

module IsoDoc
  class Metadata
    attr_accessor :fonts_options, :labels, :localdir

    def ns(xpath)
      Common::ns(xpath)
    end

    def l10n(expr, lang = @lang, script = @script, locale = @locale)
      @i18n.l10n(expr, lang, script, locale)
    end

    def connectives_strip(text)
      text.gsub("<conn>", "")
        .gsub("</conn>", "")
        .gsub("<enum-comma>", "")
        .gsub("</enum-comma>", "")
        .gsub("<comma>", "")
        .gsub("</comma>", "")
    end

    def initialize(lang, script, locale, i18n, fonts_options = {})
      @metadata = { lang:, script: }
      DATETYPES.each { |w| @metadata["#{w.tr('-', '_')}date".to_sym] = "XXX" }
      @lang = lang
      @script = script
      @locale = locale
      @c = HTMLEntities.new
      @i18n = i18n
      @labels = @i18n.get
      @fonts_options = fonts_options
    end

    def get
      @metadata
    end

    def set(key, value)
      @metadata[key] = value
    end

    NOLANG = "[not(@language) or @language = '']".freeze

    def currlang
      "[@language = '#{@lang}']"
    end

    def doctype(isoxml, _out)
      b = isoxml.at(ns("//bibdata/ext/doctype#{NOLANG}")) || return
      set(:doctype, status_print(b.text))
      b1 = isoxml.at(ns("//bibdata/ext/doctype#{currlang}")) || b
      set(:doctype_display, status_print(b1.text))
      b = isoxml.at(ns("//bibdata/ext/subdoctype#{NOLANG}")) || return
      set(:subdoctype, status_print(b.text))
    end

    def docstatus(xml, _out)
      published = published_default(xml)
      s = xml.at(ns("//bibdata/status/stage#{NOLANG}")) or return
      s1 = xml.at(ns("//bibdata/status/stage#{currlang}")) || s
      set(:stage, status_print(s.text))
      s1 and set(:stage_display, status_print(s1.text))
      (i = xml.at(ns("//bibdata/status/substage#{NOLANG}"))&.text) and
        set(:substage, i)
      (i1 = xml.at(ns("//bibdata/status/substage#{currlang}"))&.text || i) and
        set(:substage_display, i1)
      (i2 = xml.at(ns("//bibdata/status/iteration"))&.text) and
        set(:iteration, i2)
      !published && set(:stageabbr, stage_abbr(s.text))
    end

    def published_default(xml)
      override = xml.at(ns("//semantic-metadata/stage-published"))&.text
      default = override || "true"
      ret = default == "false"
      set(:unpublished, ret)
      default == "true"
    end

    def stage_abbr(docstatus)
      status_print(docstatus).split(/ /).map { |s| s[0].upcase }.join
    end

    # KILL
    def unpublishedx(status)
      !status.casecmp("published").zero?
    end

    def status_print(status)
      status.split(/[- ]/).map do |w|
        letters = w.chars
        letters.first.upcase!
        letters.join
      end.join(" ")
    end

    def docid(isoxml, _out)
      dn = isoxml.at(ns("//bibdata/docidentifier"))
      set(:docnumber, dn&.text)
    end

    def otherid(isoxml, _out)
      dn = isoxml.at(ns('//bibdata/docidentifier[@type = "ISBN"]'))
      set(:isbn, dn&.text)
      dn = isoxml.at(ns('//bibdata/docidentifier[@type = "ISBN10"]'))
      set(:isbn10, dn&.text)
    end

    def docnumeric(isoxml, _out)
      dn = isoxml.at(ns("//bibdata/docnumber"))
      set(:docnumeric, dn&.text)
    end

    def draftinfo(draft, revdate)
      return "" unless draft

      draftinfo = " (#{@labels['draft_label']} #{draft}"
      draftinfo += ", #{revdate}" if revdate
      draftinfo += ")"
      l10n(draftinfo, @lang, @script, @locale)
    end

    def version(isoxml, _out)
      set(:edition, isoxml.at(ns("//bibdata/edition#{NOLANG}"))&.text)
      set(:edition_display,
          isoxml.at(ns("//bibdata/edition#{currlang}"))&.text)
      set(:docyear, isoxml.at(ns("//bibdata/copyright/from"))&.text)
      set(:draft, isoxml.at(ns("//bibdata/version/draft"))&.text)
      revdate = isoxml.at(ns("//bibdata/version/revision-date"))&.text
      set(:revdate, revdate)
      set(:revdate_monthyear, monthyr(revdate))
      set(:draftinfo,
          draftinfo(get[:draft], get[:revdate]))
    end

    def title(isoxml, _out)
      main = isoxml.at(ns("//bibdata/title[@language='#{@lang}']"))
        &.children and set(:doctitle, to_xml(main))
    end

    def subtitle(_isoxml, _out)
      nil
    end

    def relations(isoxml, _out)
      relations_obsoletes(isoxml)
      relations_partof(isoxml)
    end

    def relations_partof(isoxml)
      std = isoxml.at(ns("//bibdata/relation[@type = 'partOf']")) || return
      id = std.at(ns(".//docidentifier"))
      set(:partof, id.text) if id
    end

    def relations_obsoletes(isoxml)
      std = isoxml.at(ns("//bibdata/relation[@type = 'obsoletes']")) || return
      locality = std.at(ns(".//locality"))
      id = std.at(ns(".//docidentifier"))
      set(:obsoletes, id.text) if id
      set(:obsoletes_part, locality.text) if locality
    end

    def url(xml, _out)
      (a = xml.at(ns("//bibdata/uri[not(@type)]"))) && set(:url, a.text)
      (a = xml.at(ns("//bibdata/uri[@type = 'html']"))) && set(:html, a.text)
      (a = xml.at(ns("//bibdata/uri[@type = 'xml']"))) && set(:xml, a.text)
      (a = xml.at(ns("//bibdata/uri[@type = 'pdf']"))) && set(:pdf, a.text)
      (a = xml.at(ns("//bibdata/uri[@type = 'doc']"))) && set(:doc, a.text)
    end

    def keywords(isoxml, _out)
      ret = []
      isoxml.xpath(ns("//bibdata/keyword")).each { |kw| ret << kw.text }
      set(:keywords, ret)
    end

    def note(isoxml, _out)
      ret = []
      isoxml.xpath(ns("//bibdata/note[@type = 'title-footnote']")).each do |n|
        ret << n.text
      end
      set(:title_footnote, ret)
    end

    def code_css(isoxml, _out)
      c = isoxml.at(ns("//metanorma-extension/source-highlighter-css")) or return
      set(:code_css, c.text)
    end

    def presentation(xml, _out)
      xml.xpath(ns("//metanorma-extension/presentation-metadata")).each do |p|
        ((n = p.at(ns("./name"))) && (v = p.at(ns("./value")))) or next
        lbl = "presentation_metadata_#{n.text}".to_sym
        m = get[lbl] || []
        set(lbl, m << v.text)
      end
    end

    include ::IsoDoc::ClassUtils
  end
end
