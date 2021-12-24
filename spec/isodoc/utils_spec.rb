require "spec_helper"

RSpec.describe IsoDoc::ClassUtils do
  it "cases text" do
    expect(::IsoDoc::Common.case_strict("ABC CDE", "lowercase", "Hans"))
      .to eq "ABC CDE"
    expect(::IsoDoc::Common.case_strict("ABC CDE", "lowercase", "Latn"))
      .to eq "aBC CDE"
    expect(::IsoDoc::Common.case_strict("abc cde", "capital", "Latn"))
      .to eq "Abc cde"
    expect(::IsoDoc::Common.case_strict("abc cde", "allcaps", "Latn"))
      .to eq "ABC cde"
    expect(::IsoDoc::Common.case_strict("ABC CDE", "lowercase", "Hans", firstonly: true))
      .to eq "ABC CDE"
    expect(::IsoDoc::Common.case_strict("ABC CDE", "lowercase", "Latn", firstonly: true))
      .to eq "aBC CDE"
    expect(::IsoDoc::Common.case_strict("abc cde", "capital", "Latn", firstonly: true))
      .to eq "Abc cde"
    expect(::IsoDoc::Common.case_strict("abc cde", "allcaps", "Latn", firstonly: true))
      .to eq "ABC cde"
    expect(::IsoDoc::Common.case_strict("ABC CDE", "lowercase", "Hans", firstonly: false))
      .to eq "ABC CDE"
    expect(::IsoDoc::Common.case_strict("ABC CDE", "lowercase", "Latn", firstonly: false))
      .to eq "aBC cDE"
    expect(::IsoDoc::Common.case_strict("abc cde", "capital", "Latn", firstonly: false))
      .to eq "Abc Cde"
    expect(::IsoDoc::Common.case_strict("abc cde", "allcaps", "Latn", firstonly: false))
      .to eq "ABC CDE"
  end

  it "cases text with formatting" do
    expect(::IsoDoc::Common
      .case_with_markup("<a>ABC</a> CDE", "lowercase", "Hans"))
      .to eq "<a>ABC</a> CDE"
    expect(::IsoDoc::Common
      .case_with_markup("<a>ABC</a> CDE", "lowercase", "Latn"))
      .to eq "<a>aBC</a> CDE"
    expect(::IsoDoc::Common
      .case_with_markup("<a>abc</a> cde", "capital", "Latn"))
      .to eq "<a>Abc</a> cde"
    expect(::IsoDoc::Common
      .case_with_markup("<a>abc</a> cde", "allcaps", "Latn"))
      .to eq "<a>ABC</a> cde"
    expect(::IsoDoc::Common
      .case_with_markup("<a>ABC</a> CDE", "lowercase", "Hans", firstonly: false))
      .to eq "<a>ABC</a> CDE"
    expect(::IsoDoc::Common
      .case_with_markup("<a>ABC</a> CDE", "lowercase", "Latn", firstonly: false))
      .to eq "<a>aBC</a> cDE"
    expect(::IsoDoc::Common
      .case_with_markup("<a>abc</a> cde", "capital", "Latn", firstonly: false))
      .to eq "<a>Abc</a> Cde"
    expect(::IsoDoc::Common
      .case_with_markup("<a>abc</a> cde", "allcaps", "Latn", firstonly: false))
      .to eq "<a>ABC</a> CDE"
  end
end
