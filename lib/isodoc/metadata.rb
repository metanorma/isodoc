require "htmlentities"

module IsoDoc
  class Convert
    DATETYPES = %w{published accessed created activated obsoleted confirmed
    updated issued}.freeze

    def init_metadata
      @meta = { tc: "XXXX", sc: "XXXX", wg: "XXXX",
                editorialgroup: [],
                secretariat: "XXXX",
                obsoletes: nil,
                obsoletes_part: nil }
      DATETYPES.each { |w| @meta["#{w}date".to_sym] = "XXX" }
    end

    def get_metadata
      @meta
    end

    def set_metadata(key, value)
      @meta[key] = value
    end

    def author(xml, _out)
      tc(xml)
      sc(xml)
      wg(xml)
      secretariat(xml)
      agency(xml)
    end

    def tc(xml)
      tc_num = xml.at(ns("//editorialgroup/technical-committee/@number"))
      tc_type = xml.at(ns("//editorialgroup/technical-committee/@type"))&.
        text || "TC"
      if tc_num
        tcid = "#{tc_type} #{tc_num.text}"
        set_metadata(:tc,  tcid)
        set_metadata(:editorialgroup, get_metadata[:editorialgroup] << tcid)
      end
    end

    def sc(xml)
      sc_num = xml.at(ns("//editorialgroup/subcommittee/@number"))
      sc_type = xml.at(ns("//editorialgroup/subcommittee/@type"))&.text || "SC"
      if sc_num
        scid = "#{sc_type} #{sc_num.text}"
        set_metadata(:sc, scid)
        set_metadata(:editorialgroup, get_metadata[:editorialgroup] << scid)
      end
    end

    def wg(xml)
      wg_num = xml.at(ns("//editorialgroup/workgroup/@number"))
      wg_type = xml.at(ns("//editorialgroup/workgroup/@type"))&.text || "WG"
      if wg_num
        wgid = "#{wg_type} #{wg_num.text}"
        set_metadata(:wg, wgid)
        set_metadata(:editorialgroup, get_metadata[:editorialgroup] << wgid)
      end
    end

    def secretariat(xml)
      sec = xml.at(ns("//editorialgroup/secretariat"))
      set_metadata(:secretariat, sec.text) if sec
    end

    def date_range(date)
      from = date.at(ns("./from"))
      to = date.at(ns("./to"))
      ret = from.text
      ret += "&ndash;#{to.text}" if to
      ret
    end

    def bibdate(isoxml, _out)
      isoxml.xpath(ns("//bibdata/date")).each do |d|
        set_metadata("#{d['type']}date".to_sym, date_range(d))
      end
    end

    def doctype(isoxml, _out)
      b = isoxml.at(ns("//bibdata")) || return
      return unless b["type"]
      t = b["type"].split(/-/).map{ |w| w.capitalize }.join(" ")
      set_metadata(:doctype, t)
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
      set_metadata(:agency, agency.sub(%r{/$}, ""))
    end

    def docnumber(isoxml)
      docnumber = isoxml.at(ns("//project-number"))
      partnumber = isoxml.at(ns("//project-number/@part"))
      subpartnumber = isoxml.at(ns("//project-number/@subpart"))
      dn = docnumber&.text || ""
      dn += "-#{partnumber.text}" if partnumber
      dn += "-#{subpartnumber.text}" if subpartnumber
      dn
    end

    def docid(isoxml, _out)
      dn = docnumber(isoxml)
      docstatus = isoxml.at(ns("//status/stage"))
      if docstatus
        set_metadata(:stage, docstatus.text)
        abbr = stage_abbrev(docstatus.text, isoxml.at(ns("//status/iteration")),
                            isoxml.at(ns("//version/draft")))
        set_metadata(:stageabbr, abbr)
        (docstatus.text.to_i < 60) && dn = abbr + " " + dn
      end
      set_metadata(:docnumber, dn)
    end

    def draftinfo(draft, revdate)
      draftinfo = ""
      if draft
        draftinfo = " (#{@draft_lbl} #{draft}"
        draftinfo += ", #{revdate}" if revdate
        draftinfo += ")"
      end
      l10n(draftinfo)
    end

    def version(isoxml, _out)
      set_metadata(:docyear, isoxml&.at(ns("//copyright/from"))&.text)
      set_metadata(:draft, isoxml&.at(ns("//version/draft"))&.text)
      set_metadata(:revdate, isoxml&.at(ns("//version/revision-date"))&.text)
      set_metadata(:draftinfo,
                   draftinfo(get_metadata[:draft], get_metadata[:revdate]))
    end

    # we don't leave this to i18n.rb, because we have both English and
    # French titles in the same document
    def part_label(lang)
      case lang
      when "en" then "Part"
      when "fr" then "Partie"
      end
    end

    def compose_title(main, intro, part, partnum, subpartnum, lang)
      main = main.nil? ? "" : @c.encode(main.text, :hexadecimal)
      intro &&
        main = "#{@c.encode(intro.text, :hexadecimal)}&nbsp;&mdash; #{main}"
      if part
        suffix = @c.encode(part.text, :hexadecimal)
        partnum = "#{partnum}&ndash;#{subpartnum}" if partnum && subpartnum
        suffix = "#{part_label(lang)}&nbsp;#{partnum}: " + suffix if partnum
        main = "#{main}&nbsp;&mdash; #{suffix}"
      end
      main
    end

    def title(isoxml, _out)
      intro = isoxml.at(ns("//title-intro[@language='en']"))
      main = isoxml.at(ns("//title-main[@language='en']"))
      part = isoxml.at(ns("//title-part[@language='en']"))
      partnumber = isoxml.at(ns("//project-number/@part"))
      subpartnumber = isoxml.at(ns("//project-number/@subpart"))
      main = compose_title(main, intro, part, partnumber, subpartnumber, "en")
      set_metadata(:doctitle, main)
    end

    def subtitle(isoxml, _out)
      intro = isoxml.at(ns("//title-intro[@language='fr']"))
      main = isoxml.at(ns("//title-main[@language='fr']"))
      part = isoxml.at(ns("//title-part[@language='fr']"))
      partnumber = isoxml.at(ns("//project-number/@part"))
      subpartnumber = isoxml.at(ns("//project-number/@subpart"))
      main = compose_title(main, intro, part, partnumber, subpartnumber, "fr")
      set_metadata(:docsubtitle, main)
    end

    def relations(isoxml, _out)
      std = isoxml.at(ns("//bibdata/relation[@type = 'obsoletes']")) || return
      locality = std.at(ns(".//locality"))
      id = std.at(ns(".//docidentifier"))
      set_metadata(:obsoletes, id.text) if id
      set_metadata(:obsoletes_part, locality.text) if locality
    end
  end
end
