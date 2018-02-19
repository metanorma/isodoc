module IsoDoc
  class Convert
    @anchors = {}

    def get_anchors
      @anchors
    end

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
      section_names(d.at(ns("//terms")), "3", 1)
      middle_section_asset_names(d)
    end

    def middle_section_asset_names(d)
      middle_sections = "//clause[title = 'Scope'] | "\
        "//references[title = 'Normative References'] | //terms | "\
        "//symbols-abbrevs | //clause[parent::sections]"
      sequential_asset_names(d.xpath(ns(middle_sections)))
    end

    def clause_names(docxml, sect_num)
      q = "//clause[parent::sections][not(xmlns:title = 'Scope')]"
      docxml.xpath(ns(q)).each_with_index do |c, i|
        section_names(c, (i + sect_num).to_s, 1)
      end
    end

    def termnote_anchor_names(docxml)
      docxml.xpath(ns("//term[termnote]")).each do |t|
        t.xpath(ns("./termnote")).each_with_index do |n, i|
          @anchors[n["id"]] = { label: "Note #{i + 1} to entry",
                                xref: "#{@anchors[t['id']][:xref]},"\
                                "Note #{i + 1}" }
        end
      end
    end

    SECTIONS_XPATH =
        " //foreword | //introduction | //sections/terms | "\
        "//sections/clause | ./references | ./annex".freeze

    CHILD_NOTES_XPATH =
      "./*[not(self::xmlns:subsection)]//xmlns:note | ./xmlns:note".freeze

    def note_anchor_names(sections)
      sections.each do |s|
        notes = s.xpath(CHILD_NOTES_XPATH)
        notes.each_with_index do |n, i|
          next if @anchors[n["id"]]
          idx = notes.size == 1 ? "" : " #{i + 1}"
          @anchors[n["id"]] = 
            { label: "NOTE#{idx}", xref: "Note #{idx}", container: s["id"] }
        end
        note_anchor_names(s.xpath(ns("./subsection")))
      end
    end

    def middle_anchor_names(docxml)
      symbols_abbrevs = docxml.at(ns("//symbols-abbrevs"))
      sect_num = 4
      if symbols_abbrevs
        section_names(symbols_abbrevs, sect_num.to_s, 1)
        sect_num += 1
      end
      clause_names(docxml, sect_num)
      termnote_anchor_names(docxml)
    end

    # extract names for all anchors, xref and label
    def anchor_names(docxml)
      initial_anchor_names(docxml)
      middle_anchor_names(docxml)
      back_anchor_names(docxml)
      # preempt clause notes with all other types of note
      note_anchor_names(docxml.xpath(ns("//table | //example | //formula | "\
                                        "//figure")))
      note_anchor_names(docxml.xpath(ns(SECTIONS_XPATH)))
    end

    def sequential_figure_names(clause)
      i = j = 0
      clause.xpath(ns(".//figure")).each do |t|
        if t.parent.name == "figure" then j += 1
        else
          j = 0
          i += 1
        end
        label = "Figure #{i}" + (j.zero? ? "" : "-#{j}")
        @anchors[t["id"]] = { label: label, xref: label }
      end
    end

    def sequential_asset_names(clause)
      clause.xpath(ns(".//table")).each_with_index do |t, i|
        @anchors[t["id"]] = { label: "Table #{i + 1}", xref: "Table #{i + 1}" }
      end
      sequential_figure_names(clause)
      clause.xpath(ns(".//formula")).each_with_index do |t, i|
        @anchors[t["id"]] = { label: (i + 1).to_s, xref: "Formula (#{i + 1})" }
      end
      clause.xpath(ns(".//example")).each_with_index do |t, i|
        @anchors[t["id"]] = { label: (i + 1).to_s, xref: "Example (#{i + 1})" }
      end
    end

    def hierarchical_figure_names(clause, num)
      i = j = 0
      clause.xpath(ns(".//figure")).each do |t|
        if t.parent.name == "figure" then j += 1
        else
          j = 0
          i += 1
        end
        label = "Figure #{num}.#{i}" + (j.zero? ? "" : "-#{j}")
        @anchors[t["id"]] = { label: label, xref: label }
      end
    end

    def hierarchical_asset_names(clause, num)
      clause.xpath(ns(".//table")).each_with_index do |t, i|
        @anchors[t["id"]] = { label: "Table #{num}.#{i + 1}",
                              xref: "Table #{num}.#{i + 1}" }
      end
      hierarchical_figure_names(clause, num)
      clause.xpath(ns(".//formula")).each_with_index do |t, i|
        @anchors[t["id"]] = { label: "#{num}.#{i + 1}",
                              xref: "Formula (#{num}.#{i + 1})" }
      end
      clause.xpath(ns(".//example")).each_with_index do |t, i|
        @anchors[t["id"]] = { label: "#{num}.#{i + 1}",
                              xref: "Example (#{num}.#{i + 1})" }
      end
    end

    def introduction_names(clause)
      return if clause.nil?
      clause.xpath(ns("./subsection")).each_with_index do |c, i|
        section_names1(c, "0.#{i + 1}", 2)
      end
    end

    def section_names(clause, num, level)
      @anchors[clause["id"]] = { label: num, xref: "Clause #{num}",
                                 level: level }
      clause.xpath(ns("./subsection | ./term")).each_with_index do |c, i|
        section_names1(c, "#{num}.#{i + 1}", level + 1)
      end
    end

    def section_names1(clause, num, level)
      @anchors[clause["id"]] =
        { label: num, level: level,
          xref: clause.name == "term" ? num : "Clause #{num}" }
      clause.xpath(ns("./subsection ")).
        each_with_index do |c, i|
        section_names1(c, "#{num}.#{i + 1}", level + 1)
      end
    end

    def annex_names(clause, num)
      obligation = "(Informative)"
      obligation = "(Normative)" if clause["subtype"] == "normative"
      label = "<b>Annex #{num}</b><br/>#{obligation}"
      @anchors[clause["id"]] = { label: label,
                                 xref: "Annex #{num}", level: 1 }
      clause.xpath(ns("./subsection")).each_with_index do |c, i|
        annex_names1(c, "#{num}.#{i + 1}", 2)
      end
      hierarchical_asset_names(clause, num)
    end

    def annex_names1(clause, num, level)
      @anchors[clause["id"]] = { label: num,
                                 xref: num,
                                 level: level }
      clause.xpath(ns(".//subsection")).each_with_index do |c, i|
        annex_names1(c, "#{num}.#{i + 1}", level + 1)
      end
    end

    def format_ref(ref, isopub)
      return "ISO #{ref}" if isopub
      return "[#{ref}]" if /^\d+$/.match?(ref) && !/^\[.*\]$/.match?(ref)
      ref
    end

    def reference_names(ref)
      isopub = ref.at(ns(ISO_PUBLISHER_XPATH))
      docid = ref.at(ns("./docidentifier"))
      return ref_names(ref) unless docid
      date = ref.at(ns("./date[@type = 'published']"))
      reference = format_ref(docid.text, isopub)
      reference += ": #{date.text}" if date && isopub
      @anchors[ref["id"]] = { xref: reference }
    end

    def ref_names(ref)
      linkend = ref.text
      linkend.gsub!(/[\[\]]/, "") unless /^\[\d+\]$/.match? linkend
      @anchors[ref["id"]] = { xref: linkend }
    end
  end
end
