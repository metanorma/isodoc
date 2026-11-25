require "spec_helper"
require "fileutils"

RSpec.describe "Word output determinism" do
  let(:input) do
    <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword displayorder="1"><fmt-title id="_">Foreword</fmt-title>
      <p>Body text.</p>
      </foreword></preface>
      <sections>
      <clause id="A" displayorder="2"><fmt-title>Clause A</fmt-title>
      <p>Clause text.</p>
      </clause>
      </sections>
      </iso-standard>
    INPUT
  end

  def compile(prefix)
    FileUtils.rm_f("#{prefix}.doc")
    IsoDoc::WordConvert.new(
      { wordstylesheet: "spec/assets/word.css",
        htmlstylesheet: "spec/assets/html.scss" },
    ).convert(prefix, input, false)
    File.binread("#{prefix}.doc")
  end

  # html2doc mints entropy outside isodoc's control (MIME boundary salt,
  # image part uuids); scrub it to isolate isodoc's contribution.
  def scrub(doc)
    doc.gsub(/_NextPart_[0-9a-f.]+/, "_NextPart")
      .gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/, "UUID")
  end

  it "mints bookmark ids from a deterministic per-document counter" do
    first = IsoDoc::WordConvert.new({})
    second = IsoDoc::WordConvert.new({})
    seq1 = Array.new(3) { first.bookmarkid }
    seq2 = Array.new(3) { second.bookmarkid }

    expect(seq1).to eq(%w(000000001 000000002 000000003))
    expect(seq1).to eq(seq2)
    ids = (seq1 + seq2).map { |i| "_Toc#{i}" }
    expect(ids.map(&:length).max).to be <= 40
    expect(ids).to all(match(/\A_[A-Za-z0-9]+\z/))
  end

  it "produces byte-identical Word output across runs" do
    expect(scrub(compile("det_run"))).to eq(scrub(compile("det_run")))
  end
end
