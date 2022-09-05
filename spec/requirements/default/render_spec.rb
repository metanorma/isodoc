require "spec_helper"

RSpec.describe Metanorma::Requirements::Default do
  it "processes permissions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <permission id="_"   keep-with-next="true" keep-lines-together="true" model="default">
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit><eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref></inherit>
        <subject>user</subject>
        <subject>non-user</subject>
        <classification> <tag>control-class</tag> <value>Technical</value> </classification><classification> <tag>priority</tag> <value>P0</value> </classification><classification> <tag>family</tag> <value>System and Communications Protection</value> </classification><classification> <tag>family</tag> <value>System and Communications Protocols</value> </classification>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <note id="N">This is a note</note>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
                </component>
      </permission>
          </foreword></preface>
          <bibliography><references id="_bibliography" obligation="informative" normative="false" displayorder="2">
      <title>Bibliography</title>
      <bibitem id="rfc2616" type="standard">  <fetched>2020-03-27</fetched>  <title format="text/plain" language="en" script="Latn">Hypertext Transfer Protocol — HTTP/1.1</title>  <uri type="xml">https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2616.xml</uri>  <uri type="src">https://www.rfc-editor.org/info/rfc2616</uri>  <docidentifier type="IETF">RFC 2616</docidentifier>  <docidentifier type="IETF" scope="anchor">RFC2616</docidentifier>  <docidentifier type="DOI">10.17487/RFC2616</docidentifier>  <date type="published">    <on>1999-06</on>  </date>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">R. Fielding</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">J. Gettys</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">J. Mogul</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">H. Frystyk</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">L. Masinter</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">P. Leach</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">T. Berners-Lee</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <language>en</language>  <script>Latn</script>  <abstract format="text/plain" language="en" script="Latn">HTTP has been in use by the World-Wide Web global information initiative since 1990. This specification defines the protocol referred to as “HTTP/1.1”, and is an update to RFC 2068.  [STANDARDS-TRACK]</abstract>  <series type="main">    <title format="text/plain" language="en" script="Latn">RFC</title>    <number>2616</number>  </series>  <place>Fremont, CA</place></bibitem>
      </references></bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface><foreword displayorder="1">
          <permission id="_" keep-with-next="true" keep-lines-together="true" model="default"><name>Permission 1:<br/>/ogc/recommendation/wfs/2</name><p><em>Subject: user</em><br/>
      <em>Subject: non-user</em><br/>
      <em>Inherits: /ss/584/2015/level/1</em><br/>
      <em>Inherits: <eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref></em><br/>
      <em>Control-class: Technical</em><br/>
      <em>Priority: P0</em><br/>
      <em>Family: System and Communications Protection</em><br/>
      <em>Family: System and Communications Protocols</em></p><div type="requirement-description">
          <p id="_">I recommend <em>this</em>.</p>
        </div>
        <note id="N"><name>NOTE</name>This is a note</note>
        <div type="requirement-description">
          <p id="_">As for the measurement targets,</p>
        </div><div exclude="false" type="requirement-measurement-target">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_"><name>1</name>
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </div><div exclude="false" type="requirement-verification">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </div><div exclude="false" class="component1" type="requirement-component1">
                  <p id="_">Hello</p>
                </div></permission>
          </foreword></preface>
          <bibliography><references id="_bibliography" obligation="informative" normative="false" displayorder="2">
      <title depth="1">Bibliography</title>
      <bibitem id="rfc2616" type="standard"><formattedref>R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE. <em>Hypertext Transfer Protocol&#x2009;&#x2014;&#x2009;HTTP/1.1</em>. In: RFC. June 1999. Fremont, CA. <link target="https://www.rfc-editor.org/info/rfc2616">https://www.rfc-editor.org/info/rfc2616</link>.</formattedref><uri type="xml">https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2616.xml</uri><uri type="src">https://www.rfc-editor.org/info/rfc2616</uri><docidentifier type="metanorma-ordinal">[1]</docidentifier><docidentifier type="IETF">IETF RFC 2616</docidentifier><docidentifier type="IETF" scope="anchor">IETF RFC2616</docidentifier><docidentifier type="DOI">DOI 10.17487/RFC2616</docidentifier></bibitem>
      </references></bibliography>
          </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
  end

  it "processes requirements" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <requirement id="A" unnumbered="true"  keep-with-next="true" keep-lines-together="true" model="default">
        <title>A New Requirement</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <subject>user</subject>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false"  keep-with-next="true" keep-lines-together="true">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="B">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
                </component>
      </requirement>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface><foreword displayorder="1">
          <requirement id="A" unnumbered="true" keep-with-next="true" keep-lines-together="true" model="default"><name>Requirement:<br/>/ogc/recommendation/wfs/2. A New Requirement</name><p><em>Subject: user</em><br/>
      <em>Inherits: /ss/584/2015/level/1</em></p><div type="requirement-description">
          <p id="_">I recommend <em>this</em>.</p>
        </div><div type="requirement-description">
          <p id="_">As for the measurement targets,</p>
        </div><div exclude="false" keep-with-next="true" keep-lines-together="true" type="requirement-measurement-target">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="B"><name>1</name>
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </div><div exclude="false" type="requirement-verification">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </div><div exclude="false" class="component1" type="requirement-component1">
                  <p id="_">Hello</p>
                </div></requirement>
          </foreword></preface>
          </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
  .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
  end

  it "processes requirements in French" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>fr</language>
          <script>Latn</script>
          </bibdata>
          <preface><foreword>
          <requirement id="A" unnumbered="true" model="default">
        <title>A New Requirement</title>
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <subject>user</subject>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="B">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
                </component>
      </requirement>
          </foreword></preface>
          </iso-standard>
    INPUT

    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
          <language current="true">fr</language>
          <script current="true">Latn</script>
          </bibdata>
          <preface><foreword displayorder="1">
          <requirement id="A" unnumbered="true" model="default"><name>Exigence:<br/>/ogc/recommendation/wfs/2. A New Requirement</name><p><em>Sujet: user</em><br/>
      <em>H&#xE9;rite: /ss/584/2015/level/1</em></p><div type="requirement-description">
          <p id="_">I recommend <em>this</em>.</p>
        </div><div type="requirement-description">
          <p id="_">As for the measurement targets,</p>
        </div><div exclude="false" type="requirement-measurement-target">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="B"><name>1</name>
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </div><div exclude="false" type="requirement-verification">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
        if (success)
        recommendation(label: success-response)
       end
       </sourcecode>
        </div><div exclude="false" class="component1" type="requirement-component1">
                  <p id="_">Hello</p>
                </div></requirement>
          </foreword></preface>
          </iso-standard>
    OUTPUT

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end

  it "processes recommendation" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <recommendation id="_" obligation="shall,could"   keep-with-next="true" keep-lines-together="true" model="default">
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <classification><tag>type</tag><value>text</value></classification>
        <classification><tag>language</tag><value>BASIC</value></classification>
        <subject>user</subject>
        <description>
          <p id="_">I recommend <em>this</em>.</p>
        </description>
        <specification exclude="true" type="tabular">
          <p id="_">This is the object of the recommendation:</p>
          <table id="_">
            <tbody>
              <tr>
                <td style="text-align:left;">Object</td>
                <td style="text-align:left;">Value</td>
              </tr>
              <tr>
                <td style="text-align:left;">Mission</td>
                <td style="text-align:left;">Accomplished</td>
              </tr>
            </tbody>
          </table>
        </specification>
        <description>
          <p id="_">As for the measurement targets,</p>
        </description>
        <measurement-target exclude="false">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="_">success-response()</sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
                </component>
      </recommendation>
          </foreword></preface>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface><foreword displayorder="1">
          <recommendation id="_" obligation="shall,could" keep-with-next="true" keep-lines-together="true" model="default"><name>Recommendation 1:<br/>/ogc/recommendation/wfs/2</name><p><em>Obligation: shall,could</em><br/>
      <em>Subject: user</em><br/>
      <em>Inherits: /ss/584/2015/level/1</em><br/>
      <em>Type: text</em><br/>
      <em>Language: BASIC</em></p><div type="requirement-description">
          <p id="_">I recommend <em>this</em>.</p>
        </div><div type="requirement-description">
          <p id="_">As for the measurement targets,</p>
        </div><div exclude="false" type="requirement-measurement-target">
          <p id="_">The measurement target shall be measured as:</p>
          <formula id="_"><name>1</name>
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </div><div exclude="false" type="requirement-verification">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="_">CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </sourcecode>
        </div><div exclude="false" class="component1" type="requirement-component1">
                  <p id="_">Hello</p>
                </div></recommendation>
          </foreword></preface>
          </iso-standard>
    OUTPUT

    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
  end
end
