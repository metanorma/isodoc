require "htmlentities"

module IsoDoc
  class Metadata
    DATETYPES = %w{published accessed created implemented obsoleted confirmed
    updated issued}.freeze

    def ns(xpath)
      Common::ns(xpath)
    end

    def initialize(lang, script, labels)
      @metadata = { tc: "XXXX", sc: "XXXX", wg: "XXXX",
                    editorialgroup: [],
                    secretariat: "XXXX",
                    obsoletes: nil,
                    obsoletes_part: nil }
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
      tc_num = xml.at(ns("//editorialgroup/technical-committee/@number"))
      tc_type = xml.at(ns("//editorialgroup/technical-committee/@type"))&.
        text || "TC"
      if tc_num
        tcid = "#{tc_type} #{tc_num.text}"
        set(:tc,  tcid)
        set(:editorialgroup, get[:editorialgroup] << tcid)
      end
    end

    def sc(xml)
      sc_num = xml.at(ns("//editorialgroup/subcommittee/@number"))
      sc_type = xml.at(ns("//editorialgroup/subcommittee/@type"))&.text || "SC"
      if sc_num
        scid = "#{sc_type} #{sc_num.text}"
        set(:sc, scid)
        set(:editorialgroup, get[:editorialgroup] << scid)
      end
    end

    def wg(xml)
      wg_num = xml.at(ns("//editorialgroup/workgroup/@number"))
      wg_type = xml.at(ns("//editorialgroup/workgroup/@type"))&.text || "WG"
      if wg_num
        wgid = "#{wg_type} #{wg_num.text}"
        set(:wg, wgid)
        set(:editorialgroup, get[:editorialgroup] << wgid)
      end
    end

    def secretariat(xml)
      sec = xml.at(ns("//editorialgroup/secretariat"))
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
      t = b["type"].split(/-/).map{ |w| w.capitalize }.join(" ")
      set(:doctype, t)
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

    def docnumber(isoxml)
      docnumber = isoxml.at(ns("//project-number"))
      partnumber = isoxml.at(ns("//project-number/@part"))
      subpartnumber = isoxml.at(ns("//project-number/@subpart"))
      dn = docnumber&.text || ""
      dn += "-#{partnumber.text}" if partnumber
      dn += "-#{subpartnumber.text}" if subpartnumber
      dn
    end

    STAGE_ABBRS = {
      "00": "PWI",
      "10": "NWIP",
      "20": "WD",
      "30": "CD",
      "40": "DIS",
      "50": "FDIS",
      "60": "IS",
      "90": "(Review)",
      "95": "(Withdrawal)",
    }.freeze

    def stage_abbrev(stage, iter, draft)
      stage = STAGE_ABBRS[stage.to_sym] || "??"
      stage += iter.text if iter
      stage = "Pre" + stage if draft&.text =~ /^0\./
      stage
    end

    def docstatus(isoxml, _out)
      docstatus = isoxml.at(ns("//status/stage"))
      if docstatus
        set(:stage, docstatus.text)
        abbr = stage_abbrev(docstatus.text, isoxml.at(ns("//status/iteration")),
                            isoxml.at(ns("//version/draft")))
        set(:stageabbr, abbr)
      end
    end

    def docid(isoxml, _out)
      dn = docnumber(isoxml)
      docstatus = get[:stage]
      if docstatus
        abbr = get[:stageabbr]
        docstatus = get[:stage]
        (docstatus.to_i < 60) && dn = abbr + " " + dn
      end
      set(:docnumber, dn)
    end

    def draftinfo(draft, revdate)
      draftinfo = ""
      if draft
        draftinfo = " (#{@labels["draft"]} #{draft}"
        draftinfo += ", #{revdate}" if revdate
        draftinfo += ")"
      end
      Common::l10n(draftinfo, @lang, @script)
    end

    def version(isoxml, _out)
      set(:docyear, isoxml&.at(ns("//copyright/from"))&.text)
      set(:draft, isoxml&.at(ns("//version/draft"))&.text)
      set(:revdate, isoxml&.at(ns("//version/revision-date"))&.text)
      set(:draftinfo,
          draftinfo(get[:draft], get[:revdate]))
    end

    # we don't leave this to i18n.rb, because we have both English and
    # French titles in the same document
    def part_label(lang)
      case lang
      when "en" then "Part"
      when "fr" then "Partie"
      end
    end

    def part_title(part, partnum, subpartnum, lang)
      return "" unless part
      suffix = @c.encode(part.text, :hexadecimal)
      partnum = "#{partnum}&ndash;#{subpartnum}" if partnum && subpartnum
      suffix = "#{part_label(lang)}&nbsp;#{partnum}: " + suffix if partnum
      suffix
    end

    def compose_title(main, intro, part, partnum, subpartnum, lang)
      main = main.nil? ? "" : @c.encode(main.text, :hexadecimal)
      intro &&
        main = "#{@c.encode(intro.text, :hexadecimal)}&nbsp;&mdash; #{main}"
      if part
        suffix = part_title(part, partnum, subpartnum, lang)
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
      #set(:doctitlemain, main)
      main = compose_title(main, intro, part, partnumber, subpartnumber, "en")
      set(:doctitle, main)
      #set(:doctitleintro, intro)
      #set(:doctitlepart, part_title(part, partnumber, subpartnumber, "en"))
    end

    def subtitle(isoxml, _out)
      intro = isoxml.at(ns("//title-intro[@language='fr']"))
      main = isoxml.at(ns("//title-main[@language='fr']"))
      part = isoxml.at(ns("//title-part[@language='fr']"))
      partnumber = isoxml.at(ns("//project-number/@part"))
      subpartnumber = isoxml.at(ns("//project-number/@subpart"))
      #set(:docsubtitlemain, main)
      main = compose_title(main, intro, part, partnumber, subpartnumber, "fr")
      set(:docsubtitle, main)
      #set(:docsubtitleintro, intro)
      #set(:docsubtitlepart, part_title(part, partnumber, subpartnumber, "fr"))
    end

    def relations(isoxml, _out)
      std = isoxml.at(ns("//bibdata/relation[@type = 'obsoletes']")) || return
      locality = std.at(ns(".//locality"))
      id = std.at(ns(".//docidentifier"))
      set(:obsoletes, id.text) if id
      set(:obsoletes_part, locality.text) if locality
    end
  end
end
