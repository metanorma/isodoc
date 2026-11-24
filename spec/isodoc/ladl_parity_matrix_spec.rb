require "spec_helper"

# Needs Gemfile.ladl-parity (metanorma-ladl is not a dependency of isodoc):
#   BUNDLE_GEMFILE=Gemfile.ladl-parity bundle exec rspec \
#     spec/isodoc/ladl_parity_matrix_spec.rb
LADL_PARITY_LOADABLE =
  begin
    require "metanorma/ladl"
    true
  rescue LoadError
    false
  end

if LADL_PARITY_LOADABLE
  require_relative "../../docs/ladl-parity/matrix/generator"

  RSpec.describe LadlParity do
    let(:fixture) do
      File.expand_path("../assets/ladl_parity/basic.xml", __dir__)
    end
    let(:rows) do
      described_class::Generator.new(fixture).rows("base")
        .to_h { |row| [row.id, row] }
    end

    it "classifies every labelled fixture element" do
      expect(rows.values.map(&:kind).uniq)
        .to include("clause", "subclause", "annex", "figure", "subfigure",
                    "table", "formula", "note", "example",
                    "ordered-item-level4", "requirement", "term",
                    "footnote", "appendix")
    end

    it "records same for assets that LADL labels like isodoc" do
      same = %w[figure1 table1 formula1 annexA_fig annexA_table annexA_formula]
      expect(same.map { |id| rows[id].verdict }.uniq).to eq ["same"]
    end

    it "records different with both labels for diverging elements" do
      row = rows["figure2a"]
      expect([row.verdict, row.xref_xref, row.ladl_global])
        .to eq ["different", "Figure 2-1", "Figure 2 a)"]
    end

    it "records unsupported for kinds without a LADL labeller" do
      unsupported = %w[term1 req1 rec1 perm1 fn1 appendix1]
      expect(unsupported.map { |id| rows[id].verdict }.uniq)
        .to eq ["unsupported"]
    end

    it "renders a markdown matrix for each available flavor" do
      md = described_class.generate(fixture)
      headings = described_class::Generator.available_flavors
        .map { |flavor| "## #{flavor}:" }
      expect(md).to include("## Summary by kind", *headings)
    end
  end
else
  RSpec.describe "LADL parity matrix" do
    it "needs metanorma-ladl (use Gemfile.ladl-parity)" do
      skip "metanorma-ladl not loadable"
    end
  end
end
