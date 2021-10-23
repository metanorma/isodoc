require "spec_helper"

RSpec.describe IsoDoc do
  it "test empty pdf_options" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
      },
    )

    expect(convert.pdf_options(nil)).to eq({})
  end

  it "test empty pdf_options for nil font_manifest_file" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
        IsoDoc::XslfoPdfConvert::MN2PDF_OPTIONS => {
          IsoDoc::XslfoPdfConvert::MN2PDF_FONT_MANIFEST => nil,
        },
      },
    )

    expect(convert.pdf_options(nil)).to eq({})
  end

  it "test --font-manifest pdf_options" do
    mn2pdf_opts = {
      IsoDoc::XslfoPdfConvert::MN2PDF_FONT_MANIFEST => "/tmp/manifest.yml",
    }
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
        IsoDoc::XslfoPdfConvert::MN2PDF_OPTIONS => mn2pdf_opts,
      },
    )

    expect(convert.pdf_options(nil)).to eq(mn2pdf_opts)
  end

  it "test --param align-cross-elements pdf_options" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
        aligncrosselements: "clause table note",
      },
    )

    expect(convert.pdf_options(nil))
      .to eq({ "--param align-cross-elements=" => "clause table note" })
  end

  it "test --baseassetpath pdf_options" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
        baseassetpath: "ABC",
      },
    )

    expect(convert.pdf_options(nil))
      .to eq({ "--param baseassetpath=" => "ABC" })
  end
end
