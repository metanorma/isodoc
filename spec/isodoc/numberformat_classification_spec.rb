require "spec_helper"

# basicdoc-models#35: number-format option typing lives in isodoc; we union
# metanorma's known lists against plurimath's DEFAULT_OPTIONS and warn on any
# plurimath option metanorma has not classified (e.g. a passthrough option
# added upstream).
RSpec.describe IsoDoc::PresentationXMLConvert do
  subject(:conv) { described_class.new(language: "en", script: "Latn") }

  describe "#numberformat_unclassified_warn" do
    it "stays silent when every plurimath option is classified" do
      expect { conv.numberformat_unclassified_warn }.not_to output.to_stderr
    end

    it "warns, naming a plurimath option metanorma has not classified" do
      stub_const(
        "Plurimath::Formatter::Standard::DEFAULT_OPTIONS",
        Plurimath::Formatter::Standard::DEFAULT_OPTIONS
          .merge(brand_new_passthrough: 0),
      )
      expect { conv.numberformat_unclassified_warn }
        .to output(/not classified.*brand_new_passthrough/m).to_stderr
    end

    it "warns at most once per instance" do
      stub_const(
        "Plurimath::Formatter::Standard::DEFAULT_OPTIONS",
        Plurimath::Formatter::Standard::DEFAULT_OPTIONS
          .merge(brand_new_passthrough: 0),
      )
      $stderr = StringIO.new
      conv.numberformat_unclassified_warn # first call warns (captured)
      $stderr = STDERR
      expect { conv.numberformat_unclassified_warn }.not_to output.to_stderr
    end
  end
end
