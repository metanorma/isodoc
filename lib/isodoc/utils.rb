require "uuidtools"

module IsoDoc
  module Utils
    def ns(xpath)
      xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1").
        gsub(%r{::([a-zA-z])}, "::xmlns:\\1").
        gsub(%r{\[([a-zA-z]+ ?=)}, "[xmlns:\\1").
        gsub(%r{\[([a-zA-z]+\])}, "[xmlns:\\1")
    end

    def insert_tab(out, n)
      out.span **attr_code(style: "mso-tab-count:#{n}") do |span|
        [1..n].each { |i| span << "&#xA0; " }
      end
    end

    @@stage_abbrs = {
      "00": "PWI",
      "10": "NWIP",
      "20": "WD",
      "30": "CD",
      "40": "DIS",
      "50": "FDIS",
      "60": "IS",
      "90": "(Review)",
      "95": "(Withdrawal)",
    }.freeze

    def stage_abbreviation(stage)
      @@stage_abbrs[stage.to_sym] || "??"
    end

  end
end
