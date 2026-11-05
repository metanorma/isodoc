# frozen_string_literal: true

require "spec_helper"

# A relaton-resolved bibitem carries its availability in <uri type="src">
# (and any other typed <uri>): the rendered reference cites it as the
# URL component, in the same "Available at:" form the unresolved
# (plain-text) entries carry, hyperlinked like they are. isodoc#882.
RSpec.describe IsoDoc do
  let(:input) { <<~INPUT }
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata>
    <language>en</language>
    </bibdata>
    <preface><foreword id="_f">
    <p id="_p1"><eref bibitemid="RFC1738"/><eref bibitemid="RFC1738NOURI"/><eref bibitemid="HTML"/></p>
    </foreword></preface>
    <bibliography><references id="_refs" obligation="informative" normative="false"><title>Bibliography</title>
    <bibitem id="RFC1738" type="standard">
      <title type="main">Uniform Resource Locators (URL)</title>
      <uri type="src">https://www.rfc-editor.org/info/rfc1738</uri>
      <docidentifier type="IETF" primary="true">RFC 1738</docidentifier>
      <docidentifier type="DOI">10.17487/RFC1738</docidentifier>
      <docnumber>RFC1738</docnumber>
      <date type="published"><on>1994-12</on></date>
      <contributor><role type="author"/><person><name><formatted-initials language="en" script="Latn">T.</formatted-initials><surname language="en" script="Latn">Berners-Lee</surname><completename language="en" script="Latn">T. Berners-Lee</completename></name></person></contributor>
      <contributor><role type="author"/><person><name><formatted-initials language="en" script="Latn">L.</formatted-initials><surname language="en" script="Latn">Masinter</surname><completename language="en" script="Latn">L. Masinter</completename></name></person></contributor>
      <contributor><role type="author"/><person><name><formatted-initials language="en" script="Latn">M.</formatted-initials><surname language="en" script="Latn">McCahill</surname><completename language="en" script="Latn">M. McCahill</completename></name></person></contributor>
      <contributor><role type="publisher"/><organization><name language="en">RFC Publisher</name></organization></contributor>
      <contributor><role type="authorizer"/><organization><name language="en">RFC Series</name></organization></contributor>
      <status><stage>PROPOSED STANDARD</stage></status>
    </bibitem>
    <bibitem id="RFC1738NOURI" type="standard">
      <title type="main">Uniform Resource Locators (URL)</title>
      <docidentifier type="IETF" primary="true">RFC 1738</docidentifier>
      <docidentifier type="DOI">10.17487/RFC1738</docidentifier>
      <docnumber>RFC1738</docnumber>
      <date type="published"><on>1994-12</on></date>
      <contributor><role type="author"/><person><name><formatted-initials language="en" script="Latn">T.</formatted-initials><surname language="en" script="Latn">Berners-Lee</surname><completename language="en" script="Latn">T. Berners-Lee</completename></name></person></contributor>
      <contributor><role type="publisher"/><organization><name language="en">RFC Publisher</name></organization></contributor>
    </bibitem>
    <bibitem anchor="HTML" id="_html">
      <formattedref format="application/x-isodoc+xml"><em>Hyper Text Markup Language (HTML)</em> Available at: <link target="http://www.w3.org/"/></formattedref>
      <docidentifier>HTML</docidentifier>
      <language>en</language>
      <script>Latn</script>
    </bibitem>
    </references></bibliography>
    </iso-standard>
  INPUT

  def biblio_paragraph(id)
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    output = Nokogiri::HTML5(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))
    [pres_output, output.at("//p[@class = 'Biblio' and @id = '#{id}']")]
  end

  it "renders a resolved bibitem's <uri type='src'> as the Available at link" do
    pres_output, para = biblio_paragraph("RFC1738")
    expect(para.to_xml).to be_html5_equivalent_to <<~PARA
      <p id="RFC1738" class="Biblio">[1]  IETF RFC 1738, T. Berners-Lee, L. Masinter, and M. McCahill. <i>Uniform Resource Locators (URL)</i>. Report no. RFC1738. RFC Publisher, 1994. Available at: <a href="https://www.rfc-editor.org/info/rfc1738">https://www.rfc-editor.org/info/rfc1738</a>.</p>
    PARA
    # the title is cited as text, not hyperlinked: exactly one anchor
    expect(para.xpath(".//a").size).to eq(1)
    # the availability lands in the PresentationXML formattedref as a
    # link, given the same semx/fmt-link treatment as document links
    formattedref = Nokogiri::XML(pres_output)
      .at("//xmlns:bibitem[@id = 'RFC1738']/xmlns:formattedref")
    expect(strip_guid(formattedref.to_xml)).to be_xml_equivalent_to <<~XML
      <formattedref>T. Berners-Lee, L. Masinter, and M. McCahill. <em>Uniform Resource Locators (URL)</em>. Report no. RFC1738. RFC Publisher, 1994. Available at: <link target="https://www.rfc-editor.org/info/rfc1738" id="_">https://www.rfc-editor.org/info/rfc1738</link><semx element="link" source="_"><fmt-link target="https://www.rfc-editor.org/info/rfc1738">https://www.rfc-editor.org/info/rfc1738</fmt-link></semx>.</formattedref>
    XML
  end

  it "renders a resolved bibitem without any uri unchanged" do
    _pres_output, para = biblio_paragraph("RFC1738NOURI")
    expect(para.to_xml).to be_html5_equivalent_to <<~PARA
      <p id="RFC1738NOURI" class="Biblio">[2]  IETF RFC 1738, T. Berners-Lee. <i>Uniform Resource Locators (URL)</i>. Report no. RFC1738. RFC Publisher, 1994.</p>
    PARA
    expect(para.xpath(".//a")).to be_empty
    expect(para.text).not_to include("Available at")
  end

  it "leaves the unresolved formattedref entry unchanged" do
    _pres_output, para = biblio_paragraph("HTML")
    expect(para.to_xml).to be_html5_equivalent_to <<~PARA
      <p id="HTML" class="Biblio">[3]  HTML, <i>Hyper Text Markup Language (HTML)</i> Available at: <a href="http://www.w3.org/">http://www.w3.org/</a></p>
    PARA
  end
end
