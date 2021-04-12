module IsoDoc::XrefGen
  module Sections
    def back_anchor_names(docxml)
      i = Counter.new("@")
      docxml.xpath(ns("//annex")).each do |c|
        i.increment(c)
        annex_names(c, i.print)
      end
      docxml.xpath(ns(@klass.bibliography_xpath)).each do |b|
        preface_names(b)
      end
      docxml.xpath(ns("//bibitem[not(ancestor::bibitem)]")).each do |ref|
        reference_names(ref)
      end
    end

    def initial_anchor_names(d)
      d.xpath(ns("//preface/*")).each { |c| c.element? and preface_names(c) }
      # potentially overridden in middle_section_asset_names()
      sequential_asset_names(d.xpath(ns("//preface/*")))
      n = Counter.new
      n = section_names(d.at(ns("//clause[@type = 'scope']")), n, 1)
      n = section_names(d.at(ns(@klass.norm_ref_xpath)), n, 1)
      n = section_names(d.at(ns("//sections/terms | "\
                                "//sections/clause[descendant::terms]")), n, 1)
      n = section_names(d.at(ns("//sections/definitions")), n, 1)
      clause_names(d, n)
      middle_section_asset_names(d)
      termnote_anchor_names(d)
      termexample_anchor_names(d)
    end

    def preface_clause_name(clause)
      clause.at(ns("./title"))&.text || clause.name.capitalize
    end

    SUBCLAUSES =
      "./clause | ./references | ./term  | ./terms | ./definitions".freeze

    # in StanDoc, prefaces have no numbering; they are referenced only by title
    def preface_names(clause)
      return if clause.nil?

      @anchors[clause["id"]] =
        { label: nil, level: 1, xref: preface_clause_name(clause),
          type: "clause" }
      clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
        preface_names1(c, c.at(ns("./title"))&.text,
                       "#{preface_clause_name(clause)}, #{i + 1}", 2)
      end
    end

    def preface_names1(clause, title, parent_title, level)
      label = title || parent_title
      @anchors[clause["id"]] =
        { label: nil, level: level, xref: label, type: "clause" }
      clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
        preface_names1(c, c.at(ns("./title"))&.text, "#{label} #{i + 1}",
                       level + 1)
      end
    end

    def middle_section_asset_names(d)
      middle_sections = "//clause[@type = 'scope'] | "\
        "#{@klass.norm_ref_xpath} | "\
        "//sections/terms | //preface/* | "\
        "//sections/definitions | //clause[parent::sections]"
      sequential_asset_names(d.xpath(ns(middle_sections)))
    end

    def clause_names(docxml, n)
      docxml.xpath(ns(@klass.middle_clause(docxml))).each_with_index do |c, _i|
        section_names(c, n, 1)
      end
    end

    def section_names(clause, num, lvl)
      return num if clause.nil?

      num.increment(clause)
      @anchors[clause["id"]] =
        { label: num.print, xref: l10n("#{@labels['clause']} #{num.print}"),
          level: lvl, type: "clause" }
      i = Counter.new
      clause.xpath(ns(SUBCLAUSES)).each do |c|
        i.increment(c)
        section_names1(c, "#{num.print}.#{i.print}", lvl + 1)
      end
      num
    end

    def section_names1(clause, num, level)
      @anchors[clause["id"]] =
        { label: num, level: level, xref: l10n("#{@labels['clause']} #{num}"),
          type: "clause" }
      i = Counter.new
      clause.xpath(ns(SUBCLAUSES)).each do |c|
        i.increment(c)
        section_names1(c, "#{num}.#{i.print}", level + 1)
      end
    end

    def annex_name_lbl(clause, num)
      obl = l10n("(#{@labels['inform_annex']})")
      clause["obligation"] == "normative" and
        obl = l10n("(#{@labels['norm_annex']})")
      l10n("<strong>#{@labels['annex']} #{num}</strong><br/>#{obl}")
    end

    def single_annex_special_section(clause)
      a = clause.xpath(ns("./references | ./terms | ./definitions"))
      a.size == 1 or return nil
      clause.xpath(ns("./clause | ./p | ./table | ./ol | ./ul | ./dl | "\
                      "./note | ./admonition | ./figure")).empty? or
        return nil
      a[0]
    end

    def annex_names(clause, num)
      @anchors[clause["id"]] = { label: annex_name_lbl(clause, num),
                                 type: "clause", value: num.to_s,
                                 xref: "#{@labels['annex']} #{num}", level: 1 }
      if a = single_annex_special_section(clause)
        annex_names1(a, num.to_s, 1)
      else
        i = Counter.new
        clause.xpath(ns(SUBCLAUSES)).each do |c|
          i.increment(c)
          annex_names1(c, "#{num}.#{i.print}", 2)
        end
      end
      hierarchical_asset_names(clause, num)
    end

    def annex_names1(clause, num, level)
      @anchors[clause["id"]] = { label: num, xref: "#{@labels['annex']} #{num}",
                                 level: level, type: "clause" }
      i = Counter.new
      clause.xpath(ns(SUBCLAUSES)).each do |c|
        i.increment(c)
        annex_names1(c, "#{num}.#{i.print}", level + 1)
      end
    end

    ISO_PUBLISHER_XPATH =
      "./contributor[xmlns:role/@type = 'publisher']/"\
      "organization[abbreviation = 'ISO' or xmlns:abbreviation = 'IEC' or "\
      "xmlns:name = 'International Organization for Standardization' or "\
      "xmlns:name = 'International Electrotechnical Commission']".freeze

    def reference_names(ref)
      # isopub = ref.at(ns(ISO_PUBLISHER_XPATH))
      ids = @klass.bibitem_ref_code(ref)
      identifiers = @klass.render_identifier(ids)
      # date = ref.at(ns("./date[@type = 'published']"))
      reference = @klass.docid_l10n(identifiers[0] || identifiers[1])
      @anchors[ref["id"]] = { xref: reference }
    end
  end
end
