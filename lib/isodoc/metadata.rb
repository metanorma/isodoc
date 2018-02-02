module IsoDoc
  class Convert
    @meta = {}

    def get_metadata
      @meta
    end

    def set_metadata(key, value)
      @meta[key] = value
    end

    def author(isoxml, _out)
      # tc = isoxml.at(ns("//technical-committee"))
      tc_num = isoxml.at(ns("//technical-committee/@number"))
      # sc = isoxml.at(ns("//subcommittee"))
      sc_num = isoxml.at(ns("//subcommittee/@number"))
      # wg = isoxml.at(ns("//workgroup"))
      wg_num = isoxml.at(ns("//workgroup/@number"))
      secretariat = isoxml.at(ns("//secretariat"))
      set_metadata(:tc, "XXXX")
      set_metadata(:sc, "XXXX")
      set_metadata(:wg, "XXXX")
      set_metadata(:secretariat, "XXXX")
      set_metadata(:tc,  tc_num.text) if tc_num
      set_metadata(:sc, sc_num.text) if sc_num
      set_metadata(:wg, wg_num.text) if wg_num
      set_metadata(:secretariat, secretariat.text) if secretariat
    end

    def id(isoxml, _out)
      docnumber = isoxml.at(ns("//projectnumber"))
      partnumber = isoxml.at(ns("//projectnumber/@part"))
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

    def version(isoxml, _out)
      # e =  isoxml.at(ns("//edition"))
      # out.p "Edition: #{e.text}" if e
      # e =  isoxml.at(ns("//revision_date"))
      # out.p "Revised: #{e.text}" if e
      yr =  isoxml.at(ns("//copyright/from"))
      set_metadata(:docyear, yr.text)
      # out.p "© ISO #{yr.text}" if yr
    end

    def title(isoxml, _out)
      intro = isoxml.at(ns("//title[@language='en']/title-intro"))
      main = isoxml.at(ns("//title[@language='en']/title-main"))
      part = isoxml.at(ns("//title[@language='en']/title-part"))
      partnumber = isoxml.at(ns("//id/projectnumber/@part"))
      main = main.text
      main = "#{intro.text}&nbsp;&mdash; #{main}" if intro
      if part
        main = "#{main}&nbsp;&mdash; Part&nbsp;#{partnumber}: #{part.text}"
      end
      set_metadata(:doctitle, main)
    end

    def subtitle(isoxml, _out)
      intro = isoxml.at(ns("//title[@language='fr']/title-intro"))
      main = isoxml.at(ns("//title[@language='fr']/title-main"))
      part = isoxml.at(ns("//title[@language='fr']/title-part"))
      partnumber = isoxml.at(ns("//id/projectnumber/@part"))
      main = main.text
      main = "#{intro.text}&nbsp; #{main}" if intro
      if part
        main = "#{main}&nbsp;&mdash; Part&nbsp;#{partnumber}: #{part.text}"
      end
      set_metadata(:docsubtitle, main)
    end
  end
end
