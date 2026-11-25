# frozen_string_literal: true

require "nokogiri"
require "isodoc"

# Machine-generated parity matrix for isodoc#892: runs the isodoc xref engine
# and the LADL engine (ISO/IEC profile) over the same fixture and records, per
# labelled element, whether the labels are the same, different, or whether LADL
# has no construct for the element (unsupported).
#
# Forms compared:
#   isodoc anchor(:label) text  vs  LADL label.local
#   isodoc anchor(:xref)  text  vs  LADL label.global
#
# Requires metanorma-ladl. IsoDoc::Iso / IsoDoc::Generic flavors are used when
# metanorma-iso / metanorma-generic can be loaded, and skipped otherwise.
# rubocop:disable Metrics
module LadlParity
  FLAVORS = {
    "base" => ["IsoDoc::Xref", "IsoDoc::PresentationXMLConvert", nil],
    "iso" => ["IsoDoc::Iso::Xref", "IsoDoc::Iso::PresentationXMLConvert",
              "metanorma-iso"],
    "generic" => ["IsoDoc::Generic::Xref",
                  "IsoDoc::Generic::PresentationXMLConvert",
                  "metanorma-generic"],
  }.freeze

  Row = Struct.new(:id, :kind, :ladl_type, :xref_label, :ladl_value,
                   :xref_xref, :ladl_local, :ladl_global, :verdict, :note)

  class Generator
    def self.available_flavors
      FLAVORS.select { |_, (xref, _conv, lib)| loadable?(xref, lib) }.keys
    end

    def self.loadable?(xref, lib)
      require lib if lib
      Object.const_get(xref)
      true
    rescue LoadError, NameError
      false
    end

    def initialize(fixture)
      @source = File.read(fixture)
      @doc = Nokogiri::XML(@source)
      @doc.remove_namespaces!
    end

    # Rows for one flavor, keyed by element id in document order.
    def rows(flavor)
      xrefs = build_xrefs(flavor)
      ladl, ladl_error = run_ladl
      collect_ids.map do |id, kind|
        row(id, kind, xrefs, ladl, ladl_error)
      end
    end

    def kinds_of
      collect_ids
    end

    LADL_TYPES = {
      "clause" => "clause", "subclause" => "subclause",
      "terms-clause" => "clause", "normative-references" => "clause",
      "annex-clause" => "clause", "annex-subclause" => "subclause",
      "annex" => "annex", "note" => "note", "annex-note" => "note",
      "note-single" => "note", "example" => "example",
      "annex-example" => "example", "formula" => "formula",
      "annex-formula" => "formula", "figure" => "figure",
      "annex-figure" => "figure", "subfigure" => "subfigure",
      "table" => "table", "annex-table" => "table",
      "ordered-list" => "list", "annex-ordered-list" => "list",
      "unordered-item" => "list_item_unordered",
      "ordered-item-level1" => "list_item_ordered_level1",
      "ordered-item-level2" => "list_item_ordered_level2",
      "ordered-item-level3" => "list_item_ordered_level3",
      "ordered-item-level4" => "list_item_ordered_level4"
    }.freeze

    CONTEXT = {
      "clause" => "ClauseContext", "terms-clause" => "ClauseContext",
      "normative-references" => "ClauseContext",
      "subclause" => "SubclauseContext",
      "annex" => "AnnexContext", "annex-clause" => "AnnexClauseContext",
      "annex-subclause" => "SubclauseContext",
      "ordered-list" => "ListContext", "annex-ordered-list" => "ListContext"
    }.freeze

    private

    def build_xrefs(flavor)
      xref, conv, = FLAVORS.fetch(flavor)
      pconv = Object.const_get(conv).new(language: "en", script: "Latn")
      pconv.i18n_init("en", "Latn", nil)
      xrf = Object.const_get(xref)
        .new("en", "Latn", pconv, pconv.i18n, { bibrender: pconv.bibrenderer })
      xrf.reqt_models = pconv.requirements_processor
        .new({ conv: pconv, default: "default", lang: "en", script: "Latn",
               locale: nil, labels: pconv.i18n.get })
      xrf.parse(Nokogiri::XML(@source))
      xrf
    end

    def text(frag)
      return nil if frag.nil?

      Nokogiri::HTML.fragment(frag).text.gsub(/\s+/, " ").strip
    end

    def row(id, kind, xrefs, ladl, ladl_error)
      ltype = ladl_type(kind)
      xl = text(xrefs.anchor(id, :label, false))
      xx = text(xrefs.anchor(id, :xref, false))
      rrow = Row.new(id, kind, ltype, xl, nil, xx, nil, nil)
      node = ladl&.dig(id)
      if ltype.nil?
        rrow.verdict = "unsupported"
        rrow.note = "no LADL labeller type for #{kind}"
      elsif ladl_error
        rrow.verdict = "unsupported"
        rrow.note = "LADL run failed: #{ladl_error}"
      else
        rrow.ladl_value = node&.label&.value
        rrow.ladl_local = node&.label&.local
        rrow.ladl_global = node&.label&.global
        rrow.verdict = verdict(rrow)
      end
      rrow
    end

    # The cross-reference text is the contract: isodoc anchor(:xref) must
    # equal the LADL global label.
    def verdict(row)
      if row.ladl_global.nil? && row.ladl_local.nil?
        return row.xref_xref.to_s.empty? ? "same" : "unsupported"
      end

      row.xref_xref.to_s == row.ladl_global.to_s ? "same" : "different"
    end

    # ---- fixture classification -------------------------------------------

    def collect_ids
      @collect_ids ||= @doc.xpath("//*[@id]").filter_map do |e|
        knd = kind(e)
        knd && [e["id"], knd]
      end
    end

    def ancestors(elem)
      elem.ancestors.map(&:name)
    end

    def kind(elem)
      anc = ancestors(elem)
      annex = anc.include?("annex")
      case elem.name
      when "clause" then clause_kind(anc, annex)
      when "terms" then "terms-clause"
      when "term" then "term"
      when "annex" then "annex"
      when "appendix" then "appendix"
      when "note" then annex ? "annex-note" : note_kind(elem)
      when "example" then annex ? "annex-example" : "example"
      when "formula" then annex ? "annex-formula" : "formula"
      when "figure" then figure_kind(anc, annex)
      when "table" then annex ? "annex-table" : "table"
      when "ol" then annex ? "annex-ordered-list" : "ordered-list"
      when "ul" then "unordered-list"
      when "li" then list_item_kind(elem)
      when "requirement", "recommendation", "permission" then elem.name
      when "fn" then "footnote"
      when "references"
        elem["normative"] == "true" ? "normative-references" : "bibliography"
      when "bibitem" then "bibitem"
      when "foreword", "introduction" then "preface-#{elem.name}"
      end
    end

    def clause_kind(anc, annex)
      return "preface-clause" if anc.include?("preface")

      depth = anc.count("clause")
      if annex
        depth.zero? ? "annex-clause" : "annex-subclause"
      else
        depth.zero? ? "clause" : "subclause"
      end
    end

    def note_kind(elem)
      return "preface-note" if ancestors(elem).include?("preface")

      sibs = elem.parent.xpath("./note").size
      sibs > 1 ? "note" : "note-single"
    end

    def figure_kind(anc, annex)
      return "subfigure" if anc.include?("figure")

      annex ? "annex-figure" : "figure"
    end

    def list_item_kind(elem)
      list = elem.parent
      return "unordered-item" if list.name == "ul"

      level = elem.ancestors("li").size + 1
      "ordered-item-level#{level}"
    end

    # ---- LADL --------------------------------------------------------------

    def ladl_type(kind)
      LADL_TYPES[kind]
    end

    def run_ladl
      require "metanorma/ladl"
      profile = Metanorma::Ladl::Profile.iso_iec
      index = {}
      root = Metanorma::Ladl::ContentElement.new(id: "doc", type: "document",
                                                 context: "DocumentContext")
      build_sections(root, index)
      annexes = @doc.xpath("//annex")
      annexes.each { |ann| build_node(ann, root, index) }
      Metanorma::Ladl::Engine.new(profile: profile).call(root)
      [index, nil]
    rescue StandardError => e
      [nil, "#{e.class}: #{e.message}".lines.first.strip]
    end

    # Normative references sit in <bibliography> but are clause 2, after scope.
    def build_sections(root, index)
      kids = @doc.at("//sections").element_children.to_a
      normrefs = @doc.at("//references[@normative='true']")
      pos = kids.index { |knd| knd["type"] == "scope" }
      kids.insert(pos ? pos + 1 : 0, normrefs) if normrefs
      kids.each { |c| build_node(c, root, index) }
    end

    def build(elem, parent, index)
      elem.element_children.each { |c| build_node(c, parent, index) }
    end

    def build_node(elem, parent, index)
      knd = kind(elem)
      ltype = knd && ladl_type(knd)
      if ltype.nil?
        # unsupported element: descend so that supported children keep a parent
        build(elem, parent, index)
        return
      end
      node = Metanorma::Ladl::ContentElement.new(id: elem["id"], type: ltype,
                                                 context: CONTEXT[knd])
      parent.add(node)
      index[elem["id"]] = node
      descend(elem, knd, node, index)
    end

    def descend(elem, kind, node, index)
      if kind.start_with?("ordered-item")
        wrap = Metanorma::Ladl::ContentElement.new(id: "wrap-#{elem['id']}",
                                                   type: "container",
                                                   context: "ListContext")
        node.add(wrap)
        build(elem, wrap, index)
      else
        build(elem, node, index)
      end
    end
  end

  # Renders the Markdown matrix.
  module Render
    module_function

    def cell(val)
      val.nil? || val.empty? ? "-" : val.gsub("|", "\\|")
    end

    def summary(rows_by_flavor)
      lines = ["| kind | #{rows_by_flavor.keys.join(' | ')} |",
               "|---|#{'---|' * rows_by_flavor.size}"]
      kinds = rows_by_flavor.values.first.map(&:kind).uniq
      kinds.each do |knd|
        cols = rows_by_flavor.values.map do |rows|
          rows.select { |rrow| rrow.kind == knd }.map(&:verdict).tally
            .map { |vrd, cnt| "#{vrd} #{cnt}" }.join(", ")
        end
        lines << "| #{knd} | #{cols.join(' | ')} |"
      end
      lines.join("\n")
    end

    def detail(rows)
      lines = ["| id | kind | isodoc label | LADL value | isodoc xref | " \
               "LADL local | LADL global | verdict |",
               "|---|---|---|---|---|---|---|---|"]
      rows.each do |rrow|
        lines << "| #{rrow.id} | #{rrow.kind} | #{cell(rrow.xref_label)} | " \
                 "#{cell(rrow.ladl_value)} | #{cell(rrow.xref_xref)} | " \
                 "#{cell(rrow.ladl_local)} | #{cell(rrow.ladl_global)} | " \
                 "#{rrow.verdict} |"
      end
      lines.join("\n")
    end

    def totals(rows)
      rows.map(&:verdict).tally.map { |vrd, cnt| "#{vrd} #{cnt}" }.join(", ")
    end

    def markdown(rows_by_flavor, fixture:, ladl_version:)
      out = ["# isodoc xref vs LADL parity matrix", "",
             "Fixture: `#{fixture}`. LADL: metanorma-ladl #{ladl_version}, " \
             "profile `iso_iec` (no generic LADL profile exists, so the " \
             "generic column also uses `iso_iec`).", "",
             "Verdict: isodoc `anchor(:xref)` text against LADL `global`. " \
             "`same` means equal, `different` means both produce a label " \
             "and they differ, `unsupported` means LADL has no labeller " \
             "type for the element or produced no label for it. isodoc " \
             "`anchor(:label)` and LADL `value`/`local` are shown for " \
             "information only.", "",
             "Caveat: LADL runs on its illustrative `ContentElement` tree " \
             "built from the fixture by this script, not on the native " \
             "presentation adapter. Some `unsupported` or `different` " \
             "rows (annex notes and examples, nested subclause depth) may " \
             "reflect that tree mapping rather than the profile itself.", "",
             "## Summary by kind", "", summary(rows_by_flavor), ""]
      rows_by_flavor.each do |flavor, rows|
        out << "## #{flavor}: #{totals(rows)}" << "" << detail(rows) << ""
      end
      out.join("\n")
    end
  end

  def self.generate(fixture)
    gen = Generator.new(fixture)
    flavors = Generator.available_flavors
    rows = flavors.to_h { |f| [f, gen.rows(f)] }
    require "metanorma/ladl/version"
    Render.markdown(rows, fixture: File.basename(fixture),
                          ladl_version: Metanorma::Ladl::VERSION)
  end
end

# rubocop:enable Metrics

if $PROGRAM_NAME == __FILE__
  default = File.expand_path("../../../spec/assets/ladl_parity/basic.xml",
                             __dir__)
  fixture = ARGV[0] || default
  md = LadlParity.generate(fixture)
  if ARGV[1]
    File.write(ARGV[1], md)
  else
    puts md
  end
end
