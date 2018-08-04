module IsoDoc::Function
  module XrefSectGen
    def back_anchor_names(docxml)
      docxml.xpath(ns("//annex")).each_with_index do |c, i|
        annex_names(c, (65 + i).chr.to_s)
      end
      docxml.xpath(ns("//bibitem[not(ancestor::bibitem)]")).each do |ref|
        reference_names(ref)
      end
    end

    def initial_anchor_names(d)
      preface_names(d.at(ns("//foreword")))
      preface_names(d.at(ns("//introduction")))
      n = 0
      n = section_names(d.at(ns("//clause[title = 'Scope']")), n, 1)
      n = section_names(d.at(ns(
        "//references[title = 'Normative References' or title = 'Normative references']")), n, 1)
      n = section_names(d.at(ns("//sections/terms | "\
                                "//sections/clause[descendant::terms]")), n, 1)
      n = section_names(d.at(ns("//sections/definitions")), n, 1)
      middle_section_asset_names(d)
      clause_names(d, n)
      termnote_anchor_names(d)
      termexample_anchor_names(d)
    end

    # in StanDoc, prefaces have no numbering; they are referenced only by title
    def preface_names(clause)
      return if clause.nil?
      clause.xpath(ns("./clause")).each_with_index do |c, i|
        preface_names1(c, c.at(ns("./title"))&.text, "#{clause.at(ns('./title'))&.text}, #{i+1}", 2)
      end
    end

    def preface_names1(clause, title, parent_title, level)
      label = title || parent_title
      @anchors[clause["id"]] =
        { label: nil, level: level, xref: label }
      # subclauses are not prefixed with "Clause"
      clause.xpath(ns("./clause | ./terms | ./term | ./definitions")).
        each_with_index do |c, i|
        preface_names1(c, c.at(ns("./title"))&.text, "#{label} #{i+1}", level + 1)
      end
    end

    def middle_section_asset_names(d)
      middle_sections = "//clause[title = 'Scope'] | "\
        "//foreword | //introduction | "\
        "//references[title = 'Normative References' or title = 'Normative references'] | "\
        "//sections/terms | "\
        "//sections/definitions | //clause[parent::sections]"
      sequential_asset_names(d.xpath(ns(middle_sections)))
    end

    def clause_names(docxml, sect_num)
      q = "//clause[parent::sections][not(xmlns:title = 'Scope')]"\
        "[not(descendant::terms)]"
      docxml.xpath(ns(q)).each_with_index do |c, i|
        section_names(c, (i + sect_num), 1)
      end
    end

    def section_names(clause, num, lvl)
      return num if clause.nil?
      num = num + 1
      @anchors[clause["id"]] =
        { label: num.to_s, xref: l10n("#{@clause_lbl} #{num}"), level: lvl }
      clause.xpath(ns("./clause | ./term  | ./terms | ./definitions")).
        each_with_index do |c, i|
        section_names1(c, "#{num}.#{i + 1}", lvl + 1)
      end
      num
    end

    def section_names1(clause, num, level)
      @anchors[clause["id"]] =
        { label: num, level: level, xref: num }
      # subclauses are not prefixed with "Clause"
      clause.xpath(ns("./clause | ./terms | ./term | ./definitions")).
        each_with_index do |c, i|
        section_names1(c, "#{num}.#{i + 1}", level + 1)
      end
    end

    def annex_name_lbl(clause, num)
      obl = l10n("(#{@inform_annex_lbl})")
      obl = l10n("(#{@norm_annex_lbl})") if clause["obligation"] == "normative"
      l10n("<b>#{@annex_lbl} #{num}</b><br/>#{obl}")
    end

    def annex_names(clause, num)
      @anchors[clause["id"]] = { label: annex_name_lbl(clause, num),
                                 xref: "#{@annex_lbl} #{num}", level: 1 }
      clause.xpath(ns("./clause")).each_with_index do |c, i|
        annex_names1(c, "#{num}.#{i + 1}", 2)
      end
      #appendix_names(clause, num)
      hierarchical_asset_names(clause, num)
    end

    def annex_names1(clause, num, level)
      @anchors[clause["id"]] = { label: num, xref: num, level: level }
      clause.xpath(ns(".//clause")).each_with_index do |c, i|
        annex_names1(c, "#{num}.#{i + 1}", level + 1)
      end
    end
  end
end
