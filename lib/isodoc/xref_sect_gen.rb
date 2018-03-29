module IsoDoc
  class Convert
    def back_anchor_names(docxml)
      docxml.xpath(ns("//annex")).each_with_index do |c, i|
        annex_names(c, (65 + i).chr.to_s)
      end
      docxml.xpath(ns("//bibitem")).each do |ref|
        reference_names(ref)
      end
    end

    def initial_anchor_names(d)
      introduction_names(d.at(ns("//introduction")))
      section_names(d.at(ns("//clause[title = 'Scope']")), "1", 1)
      section_names(d.at(ns(
        "//references[title = 'Normative References']")), "2", 1)
      section_names(d.at(ns("//sections/terms | "\
                            "//sections/clause[descendant::terms]")), "3", 1)
      middle_section_asset_names(d)
    end

    def middle_section_asset_names(d)
      middle_sections = "//clause[title = 'Scope'] | "\
        "//foreword | //introduction | "\
        "//references[title = 'Normative References'] | //sections/terms | "\
        "//sections/symbols-abbrevs | //clause[parent::sections]"
      sequential_asset_names(d.xpath(ns(middle_sections)))
    end

    def clause_names(docxml, sect_num)
      q = "//clause[parent::sections][not(xmlns:title = 'Scope')]"\
        "[not(descendant::terms)]"
      docxml.xpath(ns(q)).each_with_index do |c, i|
        section_names(c, (i + sect_num).to_s, 1)
      end
    end

    def introduction_names(clause)
      return if clause.nil?
      clause.xpath(ns("./clause")).each_with_index do |c, i|
        section_names1(c, "0.#{i + 1}", 2)
      end
    end

    def section_names(clause, num, lvl)
      return if clause.nil?
      @anchors[clause["id"]] =
        { label: num, xref: l10n("#{@clause_lbl} #{num}"), level: lvl }
      clause.xpath(ns("./clause | ./term  | ./terms | ./symbols-abbrevs")).
        each_with_index do |c, i|
        section_names1(c, "#{num}.#{i + 1}", lvl + 1)
      end
    end

    def section_names1(clause, num, level)
      @anchors[clause["id"]] =
        { label: num, level: level, xref: num }
      # subclauses are not prefixed with "Clause"
      clause.xpath(ns("./clause | ./terms | ./term | ./symbols-abbrevs")).
        each_with_index do |c, i|
        section_names1(c, "#{num}.#{i + 1}", level + 1)
      end
    end

    def annex_names(clause, num)
      obl = l10n("(#{@inform_annex_lbl})")
      obl = l10n("(#{@norm_annex_lbl})") if clause["obligation"] == "normative"
      label = l10n("<b>#{@annex_lbl} #{num}</b><br/>#{obl}")
      @anchors[clause["id"]] =
        { label: label, xref: "#{@annex_lbl} #{num}", level: 1 }
      clause.xpath(ns("./clause")).each_with_index do |c, i|
        annex_names1(c, "#{num}.#{i + 1}", 2)
      end
      appendix_names(clause, num)
      hierarchical_asset_names(clause, num)
    end

    def annex_names1(clause, num, level)
      @anchors[clause["id"]] = { label: num, xref: num, level: level }
      clause.xpath(ns(".//clause")).each_with_index do |c, i|
        annex_names1(c, "#{num}.#{i + 1}", level + 1)
      end
    end

    def appendix_names(clause, num)
      clause.xpath(ns("./appendix")).each_with_index do |c, i|
        @anchors[c["id"]] = anchor_struct(i + 1, nil, @appendix_lbl)
        @anchors[c["id"]][:level] = 2
        @anchors[c["id"]][:container] = clause["id"]
      end
    end
  end
end
