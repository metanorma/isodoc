require "htmlentities"

module IsoDoc
  class Convert

    def init_metadata
      @meta = {
        tc: "XXXX",
        sc: "XXXX",
        wg: "XXXX",
        editorialgroup: [],
        secretariat: "XXXX",
      }
      %w{published accessed created activated obsoleted}.each do |w|
        @meta["#{w}date".to_sym] = "XXX"
      end
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
        wgid =  "#{wg_type} #{wg_num.text}"
        set_metadata(:wg, wgid)
        set_metadata(:editorialgroup, get_metadata[:editorialgroup] << wgid)
      end
    end

    def secretariat(xml)
      sec = xml.at(ns("//editorialgroup/secretariat"))
      set_metadata(:secretariat, sec.text) if sec
    end

    def bibdate(isoxml, _out)
      isoxml.xpath(ns("//bibdata/date")).each do |d|
        set_metadata("#{d["type"]}date".to_sym, d.text)
      end
    end

    def agency(xml)
      agency = ""
      pub = xml.xpath(ns("//bibdata/contributor"\
                         "[xmlns:role/@type = 'publisher']/"\
                         "organization/name")).each do |org|
        agency = org.text == "ISO" ? "ISO/#{agency}" : "#{agency}#{org.text}/"
      end
      set_metadata(:agency, agency.sub(%r{/$}, ""))
    end

    def id(isoxml, _out)
      docnumber = isoxml.at(ns("//project-number"))
      partnumber = isoxml.at(ns("//project-number/@part"))
      documentstatus = isoxml.at(ns("//status/stage"))
      dn = docnumber.text
      dn += "-#{partnumber.text}" if partnumber
      if documentstatus
        set_metadata(:stage, documentstatus.text)
        abbr = stage_abbreviation(documentstatus.text)
        set_metadata(:stageabbr, abbr)
        documentstatus.text.to_i < 60 and
          dn = abbr + " " + dn
      end
      set_metadata(:docnumber, dn)
    end

    def draftinfo(draft, revdate)
      draftinfo = ""
      if draft
        draftinfo = " (draft #{draft.text}"
        draftinfo += ", #{revdate.text}" if revdate
        draftinfo += ")"
      end
      draftinfo
    end

    def version(isoxml, _out)
      yr = isoxml.at(ns("//copyright/from"))
      set_metadata(:docyear, yr.text)
      draft = isoxml.at(ns("//version/draft"))
      set_metadata(:draft, draft.nil? ? nil : draft.text)
      revdate = isoxml.at(ns("//version/revision-date"))
      set_metadata(:revdate, revdate.nil? ? nil : revdate.text)
      draftinfo = draftinfo(draft, revdate)
      set_metadata(:draftinfo, draftinfo(draft, revdate))
    end

    def part_label(lang)
      case lang
      when "en" then "Part"
      when "fr" then "Part"
      end
    end

    def compose_title(main, intro, part, partnum, lang)
      c = HTMLEntities.new
      main = c.encode(main.text, :hexadecimal)
      intro &&
        main = "#{c.encode(intro.text, :hexadecimal)}&nbsp;&mdash; #{main}"
      if part
        suffix = c.encode(part.text, :hexadecimal)
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
      main = compose_title(main, intro, part, partnumber, "en")
      set_metadata(:doctitle, main)
    end

    def subtitle(isoxml, _out)
      intro = isoxml.at(ns("//title-intro[@language='fr']"))
      main = isoxml.at(ns("//title-main[@language='fr']"))
      part = isoxml.at(ns("//title-part[@language='fr']"))
      partnumber = isoxml.at(ns("//project-number/@part"))
      main = compose_title(main, intro, part, partnumber, "fr")
      set_metadata(:docsubtitle, main)
    end
  end
end
