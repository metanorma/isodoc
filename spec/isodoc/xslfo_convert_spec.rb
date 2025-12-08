require "spec_helper"

RSpec.describe IsoDoc do
  it "test default pdf_options" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
      },
    )

    expect(convert.pdf_options(nil, nil)).to eq({ "--syntax-highlight": nil })
  end

  it "test default pdf_options for nil font_manifest_file" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
        IsoDoc::XslfoPdfConvert::MN_OPTIONS_KEY => {
          IsoDoc::XslfoPdfConvert::MN2PDF_FONT_MANIFEST => nil,
        },
      },
    )

    expect(convert.pdf_options(nil, nil)).to eq({ "--syntax-highlight": nil })
  end

  it "test --font-manifest pdf_options" do
    mn2pdf_opts = {
      "--syntax-highlight": nil,
      font_manifest: "/tmp/manifest.yml",
    }
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
        IsoDoc::XslfoPdfConvert::MN_OPTIONS_KEY => mn2pdf_opts,
      },
    )

    expect(convert.pdf_options(nil, nil)).to eq(mn2pdf_opts)
  end

  it "test --param align-cross-elements pdf_options" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
        aligncrosselements: "clause table note",
      },
    )

    expect(convert.pdf_options(nil, nil))
      .to eq({ "--param align-cross-elements=" => "clause table note",
               "--syntax-highlight": nil })
  end

  it "test --baseassetpath pdf_options" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
        baseassetpath: "ABC",
      },
    )

    expect(convert.pdf_options(nil, nil))
      .to eq({ "--param baseassetpath=" => "ABC",
               "--syntax-highlight": nil })

    convert = IsoDoc::XslfoPdfConvert.new(
      {
        datauriimage: false,
      },
    )

    expect(convert.pdf_options(nil, nil))
      .to eq({ "--syntax-highlight": nil })

    expect(convert.pdf_options(nil, "test.xml"))
      .to eq({ "--param baseassetpath=" => File.expand_path("."),
               "--syntax-highlight": nil })
  end

  it "test pdf encryption options" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        pdfencryptionlength: "a",
        pdfownerpassword: "b",
        pdfuserpassword: "c",
        pdfallowprint: "d",
        pdfallowcopycontent: "e",
        pdfalloweditcontent: "f",
        pdfalloweditannotations: "g",
        pdfallowfillinforms: "h",
        pdfallowaccesscontent: "i",
        pdfallowassembledocument: "j",
        pdfallowprinthq: "k",
        pdfencryptmetadata: "l",
      },
    )

    expect(convert.pdf_options(nil, nil))
      .to eq({
               "--allow-access-content" => "i",
               "--allow-assemble-document" => "j",
               "--allow-copy-content" => "e",
               "--allow-edit-annotations" => "g",
               "--allow-edit-content" => "f",
               "--allow-fill-in-forms" => "h",
               "--allow-print" => "d",
               "--allow-print-hq" => "k",
               "--encrypt-metadata" => "l",
               "--encryption-length" => "a",
               "--owner-password" => "b",
               :"--syntax-highlight" => nil,
               "--user-password" => "c",
             })
  end

  it "test pdf portfolio options" do
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        pdfportfolio: true,
      },
    )

    expect(convert.pdf_options(nil, nil))
      .to eq({
               "--pdf-portfolio" => true,
               :"--syntax-highlight" => nil,
             })
  end

  it "passes on XSLT stylesheet" do
    stylesheet_mock("spec/assets/xsl.pdf")
    convert_mock(Pathname.new(File.join(File.dirname(__FILE__), "..", "..",
                                        "lib", "isodoc", "spec", "assets",
                                        "xsl.pdf")).cleanpath.to_s)
    IsoDoc::XslfoPdfConvert.new({})
      .convert("spec/assets/iso.xml", nil, nil, nil)

    stylesheet_mock("/spec/assets/xsl.pdf")
    convert_mock("/spec/assets/xsl.pdf")
    IsoDoc::XslfoPdfConvert.new({})
      .convert("spec/assets/iso.xml", nil, nil, nil)
  end

  it "passes on stylesheet parameters" do
    stylesheet_mock("xsl.pdf") # lib/isodoc/...
    convert = IsoDoc::XslfoPdfConvert.new(
      {
        pdfstylesheet: "../../spec/examples/xsl.pdf",
        pdfstylesheet_override: "../../lib/isodoc/xsl.pdf",
      },
    )
    baseassetpath = Pathname.new(File.join(
                                   File.dirname(__FILE__), "..", "assets"
                                 )).cleanpath.to_s
    overridepath = Pathname.new(File.join(
                                  File.dirname(__FILE__),
                                  "..", "..", "lib", "isodoc", "xsl.pdf"
                                )).cleanpath.to_s
    convert_mock(
      Pathname.new(File.join(File.dirname(__FILE__), "..", "examples",
                             "xsl.pdf")).cleanpath.to_s,
      {
        "--param baseassetpath=" => baseassetpath,
        "--syntax-highlight": nil,
        "--xsl-file-override" => overridepath,
      },
    )
    convert.convert("spec/assets/iso.xml", nil, nil, nil)
  end
end

private

def stylesheet_mock(dir)
  allow_any_instance_of(::IsoDoc::XslfoPdfConvert)
    .to receive(:pdf_stylesheet)
    .and_return(dir)
end

def convert_mock(dir, opts = nil)
  allow_any_instance_of(::Metanorma::Output::XslfoPdf)
    .to receive(:convert)
    .with(anything, anything, dir, opts || anything)
end
