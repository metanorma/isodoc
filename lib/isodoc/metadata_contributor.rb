module IsoDoc
  class Metadata
    def extract_person_names(authors)
      authors.reduce([]) do |ret, a|
        ret << if a.at(ns("./name/completename"))
                 a.at(ns("./name/completename")).text
               else
                 extract_person_name_from_components(a)
               end
      end
    end

    def extract_person_name_from_components(person)
      name = person.xpath(ns("./name/forename"))
      name.empty? and name = person.xpath(ns("./name/formatted-initials"))
      out = name.map(&:text)
      out << person.at(ns("./name/surname"))&.text
      l10n(out.compact.join(" "))
    end

    def extract_person_affiliations(authors)
      authors.reduce([]) do |m, a|
        pos = a.at(ns("./affiliation/name"))&.text
        name = a.at(ns("./affiliation/organization/name"))&.text
        subdivs = a.xpath(ns("./affiliation/organization/subdivision"))
          &.map(&:text)&.join(", ")
        location =
          a.at(ns("./affiliation/organization/address/formattedAddress"))&.text
        m << l10n([pos, name, subdivs, location].map { |x| x&.empty? ? nil : x }
          .compact.join(", "))
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
      authors = isoxml.xpath(ns("//bibdata/contributor[role/@type = 'author' " \
                                "or xmlns:role/@type = 'editor']/person"))
      set(:authors, extract_person_names(authors))
      set(:authors_affiliations, extract_person_names_affiliations(authors))
    end

    def author(xml, _out)
      personal_authors(xml)
      agency(xml)
    end

    def iso?(org)
      org[:abbr] == "ISO" ||
        org[:name] == "International Organization for Standardization"
    end

    def agency1(xml)
      agency = ""
      publisher = []
      logos = []
      agency_data(xml).each do |org|
        agency1 = org[:abbr] || org[:name]
        org[:name] and publisher << org[:name]
        org[:logo] and logos << org[:logo]
        agency = iso?(org) ? "ISO/#{agency}" : "#{agency}#{agency1}/"
      end
      [agency.sub(%r{/$}, ""), publisher, logos]
    end

    AGENCY_DATA = { subdivision: "./subdivision",
                    pub_phone: "./phone[not(@type = 'fax')]",
                    abbr: "./abbreviation",
                    logo: "./logo/image/@src",
                    pub_fax: "./phone[@type = 'fax']", pub_email: "./email",
                    pub_uri: "./uri" }.freeze

    def agency_data(xml)
      xml.xpath(ns("//bibdata/contributor[xmlns:role/@type = 'publisher']/" \
                   "organization")).each_with_object([]) do |org, m|
                     m << agency_data1(org)
                   end
    end

    def agency_data1(org)
      ret = {}
      n = org.at(ns("./name[@language = '#{@lang}']")) ||
        org.at(ns("./name")) and ret[:name] = n.text
      AGENCY_DATA.each do |k, v|
        n = org.at(ns(v)) and ret[k] = n.text
      end
      ret
    end

    def to_datauri(src)
      /^data:/.match?(src) and return src
      Vectory::Utils::datauri(src, @localdir)
    end

    def agency(xml)
      agency, publisher, logos = agency1(xml)
      set(:agency, agency)
      set(:publisher, connectives_strip(@i18n.boolean_conj(publisher, "and")))
      set(:copublisher_logos, logos.map { |l| to_datauri(l) })
      set(:copublisher_logo_attrs, contrib_logo_attrs(xml, "publisher"))
      agency_addr(xml)
    end

    def contrib_logo_attrs(xml, role)
      xml.xpath(ns("//metanorma-extension/presentation-metadata/*"))
        .each_with_object([]) do |x, m|
          contrib_logo_attr?(x, role) or next
          p = x.name.split(/[_-]/)
          idx = (p[4] || "1").to_i - 1
          m[idx] ||= {}
          m[idx][p[2]] ||= {}
          m[idx][p[2]][p[3]] = x.text
        end
    end

    def contrib_logo_attr?(elem, role)
      elem.name.start_with?("logo-#{role}-") or return false
      p = elem.name.split(/[_-]/)
      %w(doc html).include?(p[2]) &&
        %w(height width).include?(p[3]) &&
        (!p[4] || /^\d+/.match?(p[4]))
    end

    def agency_addr(xml)
      a = xml.at(ns("//bibdata/contributor[xmlns:role/@type = 'publisher'][1]/" \
                    "organization")) or return
      data = agency_data1(a)
      data.compact.each do |k, v|
        %i(name abbr logo).include?(k) and next
        set(k, v)
      end
      n = a.at(ns("./address/formattedAddress")) and
        set(:pub_address, to_xml(n.children))
    end
  end
end
