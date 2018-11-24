module IsoDoc
  class Metadata
    DATETYPES = %w{published accessed created implemented obsoleted confirmed
    updated issued received}.freeze

    def ns(xpath)
      Common::ns(xpath)
    end

    def initialize(lang, script, labels)
      @metadata = {
        tc: "XXXX",
        sc: "XXXX",
        wg: "XXXX",
        editorialgroup: [],
        secretariat: "XXXX",
        obsoletes: nil,
        obsoletes_part: nil
      }
      DATETYPES.each { |w| @metadata["#{w}date".to_sym] = "XXX" }
      @lang = lang
      @script = script
      @c = HTMLEntities.new
      @labels = labels
    end

    def get
      @metadata
    end

    def set(key, value)
      @metadata[key] = value
    end

    def author(xml, _out)
      tc(xml)
      sc(xml)
      wg(xml)
      secretariat(xml)
      agency(xml)
    end

    def tc(xml)
      tc_num = xml.at(ns("//bibdata/editorialgroup/technical-committee/@number"))
      tc_type = xml.at(ns("//bibdata/editorialgroup/technical-committee/@type"))&.
        text || "TC"
      if tc_num
        tcid = "#{tc_type} #{tc_num.text}"
        set(:tc,  tcid)
        set(:editorialgroup, get[:editorialgroup] << tcid)
      end
    end

    def sc(xml)
      sc_num = xml.at(ns("//bibdata/editorialgroup/subcommittee/@number"))
      sc_type = xml.at(ns("//bibdata/editorialgroup/subcommittee/@type"))&.text || "SC"
      if sc_num
        scid = "#{sc_type} #{sc_num.text}"
        set(:sc, scid)
        set(:editorialgroup, get[:editorialgroup] << scid)
      end
    end

    def wg(xml)
      wg_num = xml.at(ns("//bibdata/editorialgroup/workgroup/@number"))
      wg_type = xml.at(ns("//bibdata/editorialgroup/workgroup/@type"))&.text || "WG"
      if wg_num
        wgid = "#{wg_type} #{wg_num.text}"
        set(:wg, wgid)
        set(:editorialgroup, get[:editorialgroup] << wgid)
      end
    end

    def secretariat(xml)
      sec = xml.at(ns("//bibdata/editorialgroup/secretariat"))
      set(:secretariat, sec.text) if sec
    end

    def bibdate(isoxml, _out)
      isoxml.xpath(ns("//bibdata/date")).each do |d|
        set("#{d['type']}date".to_sym, Common::date_range(d))
      end
    end

    def doctype(isoxml, _out)
      b = isoxml.at(ns("//bibdata")) || return
      return unless b["type"]
      t = b["type"].split(/[- ]/).map{ |w| w.capitalize }.join(" ")
      set(:doctype, t)
      ics = []
      isoxml.xpath(ns("//bibdata/ics/code")).each { |i| ics << i.text }
      set(:ics, ics.empty? ? "XXX" : ics.join(", "))
    end

    def iso?(org)
      name = org&.at(ns("./name"))&.text
      abbrev = org&.at(ns("./abbreviation"))&.text
      (abbrev == "ISO" ||
       name == "International Organization for Standardization" )
    end

    def agency(xml)
      agency = ""
      xml.xpath(ns("//bibdata/contributor[xmlns:role/@type = 'publisher']/"\
                   "organization")).each do |org|
        name = org&.at(ns("./name"))&.text
        abbrev = org&.at(ns("./abbreviation"))&.text
        agency1 = abbrev || name
        agency = iso?(org) ?  "ISO/#{agency}" : "#{agency}#{agency1}/"
      end
      set(:agency, agency.sub(%r{/$}, ""))
    end

    def docstatus(isoxml, _out)
      docstatus = isoxml.at(ns("//bibdata/status"))
      if docstatus
        set(:status, status_print(docstatus.text))
      end
    end

    def status_print(status)
      status.split(/-/).map{ |w| w.capitalize }.join(" ")
    end

    def docid(isoxml, _out)
      dn = isoxml.at(ns("//bibdata/docidentifier"))
      set(:docnumber, dn&.text)
    end

    def draftinfo(draft, revdate)
      draftinfo = ""
      if draft
        draftinfo = " (#{@labels["draft_label"]} #{draft}"
        draftinfo += ", #{revdate}" if revdate
        draftinfo += ")"
      end
      IsoDoc::Function::I18n::l10n(draftinfo, @lang, @script)
    end

    def version(isoxml, _out)
      set(:docyear, isoxml&.at(ns("//bibdata/copyright/from"))&.text)
      set(:draft, isoxml&.at(ns("//version/draft"))&.text)
      set(:revdate, isoxml&.at(ns("//version/revision-date"))&.text)
      set(:draftinfo,
          draftinfo(get[:draft], get[:revdate]))
    end

    def title(isoxml, _out)
      main = isoxml&.at(ns("//bibdata/title[@language='en']"))&.text
      set(:doctitle, main)
    end

    def subtitle(isoxml, _out)
      nil
    end

    def relations(isoxml, _out)
      std = isoxml.at(ns("//bibdata/relation[@type = 'obsoletes']")) || return
      locality = std.at(ns(".//locality"))
      id = std.at(ns(".//docidentifier"))
      set(:obsoletes, id.text) if id
      set(:obsoletes_part, locality.text) if locality
    end

    def url(xml, _out)
      a = xml.at(ns("//bibdata/source[not(@type)]")) and set(:url, a.text)
      a = xml.at(ns("//bibdata/source[@type = 'html']")) and set(:html, a.text)
      a = xml.at(ns("//bibdata/source[@type = 'xml']")) and set(:xml, a.text)
      a = xml.at(ns("//bibdata/source[@type = 'pdf']")) and set(:pdf, a.text)
      a = xml.at(ns("//bibdata/source[@type = 'doc']")) and set(:doc, a.text)
    end
  end
end
