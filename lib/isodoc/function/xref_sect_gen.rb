module IsoDoc::Function
  module XrefSectGen
    def back_anchor_names(docxml)
      docxml.xpath(ns("//annex")).each_with_index do |c, i|
        annex_names(c, (65 + i).chr.to_s)
      end
      docxml.xpath(ns("//bibliography/clause[not(xmlns:title = 'Normative References' or xmlns:title = 'Normative references')] |"\
                   "//bibliography/references[not(xmlns:title = 'Normative References' or xmlns:title = 'Normative references')]")).each do |b|
        preface_names(b)
      end
      docxml.xpath(ns("//bibitem[not(ancestor::bibitem)]")).each do |ref|
        reference_names(ref)
      end
    end

    def initial_anchor_names(d)
      preface_names(d.at(ns("//preface/abstract")))
      preface_names(d.at(ns("//foreword")))
      preface_names(d.at(ns("//introduction")))
      preface_names(d.at(ns("//preface/clause")))
      preface_names(d.at(ns("//acknowledgements")))
      #sequential_asset_names(d.xpath(ns("//preface/abstract | //foreword | //introduction | //preface/clause | //acknowledgements")))
      n = section_names(d.at(ns("//clause[title = 'Scope']")), 0, 1)
      n = section_names(d.at(ns(
        "//bibliography/clause[title = 'Normative References' or title = 'Normative references'] |"\
        "//bibliography/references[title = 'Normative References' or title = 'Normative references']")), n, 1)
      n = section_names(d.at(ns("//sections/terms | "\
                                "//sections/clause[descendant::terms]")), n, 1)
      n = section_names(d.at(ns("//sections/definitions")), n, 1)
      clause_names(d, n)
      middle_section_asset_names(d)
      termnote_anchor_names(d)
      termexample_anchor_names(d)
    end

    def preface_clause_name(c)
      ret = c.at(ns("./title"))&.text || c.name.capitalize
      ret
    end

    SUBCLAUSES = "./clause | ./references | ./term  | ./terms | ./definitions".freeze

    # in StanDoc, prefaces have no numbering; they are referenced only by title
    def preface_names(clause)
      return if clause.nil?
      @anchors[clause["id"]] =
        { label: nil, level: 1, xref: preface_clause_name(clause), type: "clause" }
      clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
        preface_names1(c, c.at(ns("./title"))&.text, "#{preface_clause_name(clause)}, #{i+1}", 2)
      end
    end

    def preface_names1(clause, title, parent_title, level)
      label = title || parent_title
      @anchors[clause["id"]] =
        { label: nil, level: level, xref: label, type: "clause" }
      clause.xpath(ns(SUBCLAUSES)).
        each_with_index do |c, i|
        preface_names1(c, c.at(ns("./title"))&.text, "#{label} #{i+1}", level + 1)
      end
    end

    def middle_section_asset_names(d)
      middle_sections = "//clause[title = 'Scope'] | "\
        "//references[title = 'Normative References' or title = 'Normative references'] | "\
        "//sections/terms | "\
        "//preface/abstract | //foreword | //introduction | //preface/clause | //acknowledgements "\
        "//sections/definitions | //clause[parent::sections]"
      sequential_asset_names(d.xpath(ns(middle_sections)))
    end

    def clause_names(docxml, sect_num)
      q = self.class::MIDDLE_CLAUSE
      docxml.xpath(ns(q)).each_with_index do |c, i|
        section_names(c, (i + sect_num), 1)
      end
    end

    def section_names(clause, num, lvl)
      return num if clause.nil?
      num = num + 1
      @anchors[clause["id"]] =
        { label: num.to_s, xref: l10n("#{@clause_lbl} #{num}"), level: lvl, type: "clause" }
      clause.xpath(ns(SUBCLAUSES)).
        each_with_index do |c, i|
        section_names1(c, "#{num}.#{i + 1}", lvl + 1)
      end
      num
    end

    def section_names1(clause, num, level)
      @anchors[clause["id"]] =
        { label: num, level: level, xref: l10n("#{@clause_lbl} #{num}"), type: "clause" }
      clause.xpath(ns(SUBCLAUSES)).
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
      @anchors[clause["id"]] = { label: annex_name_lbl(clause, num), type: "clause",
                                 xref: "#{@annex_lbl} #{num}", level: 1 }
      clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
        annex_names1(c, "#{num}.#{i + 1}", 2)
      end
      hierarchical_asset_names(clause, num)
    end

    def annex_names1(clause, num, level)
      @anchors[clause["id"]] = { label: num, xref: "#{@annex_lbl} #{num}",
                                 level: level, type: "clause" }
      clause.xpath(ns(SUBCLAUSES)).each_with_index do |c, i|
        annex_names1(c, "#{num}.#{i + 1}", level + 1)
      end
    end
  end
end
