#require "uuidtools"

module IsoDoc
  #module Utils
  def self.ns(xpath)
    xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1").
      gsub(%r{::([a-zA-z])}, "::xmlns:\\1").
      gsub(%r{\[([a-zA-z]+ ?=)}, "[xmlns:\\1").
      gsub(%r{\[([a-zA-z]+\])}, "[xmlns:\\1")
  end

  def self.insert_tab(out, n)
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

  def self.stage_abbreviation(stage)
    @@stage_abbrs[stage.to_sym] || "??"
  end

  @@nokohead = <<~HERE
    <!DOCTYPE html SYSTEM
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head> <title></title> <meta charset="UTF-8" /> </head>
    <body> </body> </html>
  HERE


  # block for processing XML document fragments as XHTML,
  # to allow for HTMLentities
  def self.noko(&block)
    doc = ::Nokogiri::XML.parse(@@nokohead)
    fragment = doc.fragment("")
    ::Nokogiri::XML::Builder.with fragment, &block
    fragment.to_xml(encoding: "US-ASCII").lines.map do |l|
      l.gsub(/\s*\n/, "")
    end
  end

  def self.attr_code(attributes)
          attributes = attributes.reject { |_, val| val.nil? }.map
          attributes.map do |k, v|
            [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
          end.to_h
        end


end
#end
