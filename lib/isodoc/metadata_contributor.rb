module IsoDoc
  class Metadata
    def extract_person_names(authors)
      authors.reduce([]) do |ret, a|
        if a.at(ns("./name/completename"))
          ret << a.at(ns("./name/completename")).text
        else
          forenames = a.xpath(ns("./name/forename"))
          fn = forenames.each_with_object([]) { |f, m| m << f.text }
          surname = a&.at(ns("./name/surname"))&.text
          ret << "#{fn.join(' ')} #{surname}"
        end
      end
    end

    def extract_person_affiliations(authors)
      authors.reduce([]) do |m, a|
        name = a&.at(ns("./affiliation/organization/name"))&.text
        subdivs = a&.xpath(ns("./affiliation/organization/subdivision"))&.map(&:text)&.join(", ")
        name and subdivs and !subdivs.empty? and
          name = l10n("#{name}, #{subdivs}", @lang, @script)
        location = a&.at(ns("./affiliation/organization/address/formattedAddress"))&.text
        m << (if !name.nil? && !location.nil?
                l10n("#{name}, #{location}", @lang, @script)
              else
                (name || location || "")
              end)
        m
      end
    end

    def extract_person_names_affiliations(authors)
      names = extract_person_names(authors)
      affils = extract_person_affiliations(authors)
      ret = {}
      affils.each_with_index do |a, i|
        ret[a] ||= []
        ret[a] << names[i]
      end
      ret
    end

    def personal_authors(isoxml)
      authors = isoxml.xpath(ns("//bibdata/contributor[role/@type = 'author' "\
                                "or xmlns:role/@type = 'editor']/person"))
      set(:authors, extract_person_names(authors))
      set(:authors_affiliations, extract_person_names_affiliations(authors))
    end

    def author(xml, _out)
      personal_authors(xml)
      agency(xml)
    end

    def iso?(org)
      name = org&.at(ns("./name"))&.text
      abbrev = org&.at(ns("./abbreviation"))&.text
      (abbrev == "ISO" ||
       name == "International Organization for Standardization")
    end

    def agency1(xml)
      agency = ""
      publisher = []
      xml.xpath(ns("//bibdata/contributor[xmlns:role/@type = 'publisher']/"\
                   "organization")).each do |org|
        name = org&.at(ns("./name"))&.text
        agency1 = org&.at(ns("./abbreviation"))&.text || name
        publisher << name if name
        agency = iso?(org) ? "ISO/#{agency}" : "#{agency}#{agency1}/"
      end
      [agency, publisher]
    end

    def agency(xml)
      agency, publisher = agency1(xml)
      set(:agency, agency.sub(%r{/$}, ""))
      set(:publisher, @i18n.boolean_conj(publisher, "and"))
      agency_addr(xml)
    end

    def agency_addr(xml)
      a = xml.at(ns("//bibdata/contributor[xmlns:role/@type = 'publisher'][1]/"\
                    "organization")) or return
      { subdivision: "./subdivision", pub_phone: "./phone[not(@type = 'fax')]",
        pub_fax: "./phone[@type = 'fax']", pub_email: "./email",
        pub_uri: "./uri" }.each do |k, v|
          n = a.at(ns(v)) and set(k, n.text)
        end
      n = a.at(ns("./address/formattedAddress")) and
        set(:pub_address, n.children.to_xml)
    end
  end
end
