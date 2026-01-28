require "spec_helper"

RSpec.describe IsoDoc do
  it "processes permissions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <permission id="A"   keep-with-next="true" keep-lines-together="true" model="default">
        <identifier>/ogc/recommendation/wfs/2</identifier>
        <inherit>/ss/584/2015/level/1</inherit>
        <inherit><eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref></inherit>
        <subject>user</subject>
        <subject>non-user</subject>
        <classification> <tag>control-class</tag> <value>Technical</value> </classification><classification> <tag>priority</tag> <value>P0</value> </classification><classification> <tag>family</tag> <value>System and Communications Protection</value> </classification><classification> <tag>family</tag> <value>System and Communications Protocols</value> </classification>
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
          <sourcecode id="C"><body>CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </body></sourcecode>
          <note id="N1">text</note>
          <example id="E1">text</example>
        </verification>
        <import exclude="true">
          <sourcecode id="D"><body>success-response()</body></sourcecode>
        </import>
        <component exclude='false' class='component1'>
                  <p id='_'>Hello</p>
          <note id="N2">text</note>
          <example id="E2">text</example>
                </component>
      </permission>
          </foreword></preface>
          <annex id="Annex">
          <permission id="AnnexPermission" model="default">
          <description>
          <p id="_">As for the measurement targets,</p>
          <note id="N3">text</note>
          <example id="E3">text</example>
        </description>
          </permission>
          </annex>
          <bibliography><references id="_bibliography" obligation="informative" normative="false" displayorder="3">
      <title>Bibliography</title>
      <bibitem id="rfc2616" type="standard">  <fetched>2020-03-27</fetched>  <title format="text/plain" language="en" script="Latn">Hypertext Transfer Protocol\\u2009—\\u2009HTTP/1.1</title>  <docidentifier type="IETF">RFC 2616</docidentifier>  <docidentifier type="IETF" scope="anchor">RFC2616</docidentifier>  <docidentifier type="DOI">10.17487/RFC2616</docidentifier>  <date type="published">    <on>1999-06</on>  </date>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">R. Fielding</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">J. Gettys</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">J. Mogul</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">H. Frystyk</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">L. Masinter</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">P. Leach</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">T. Berners-Lee</completename>      </name>      <affiliation>        <organization>          <name>IETF</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <language>en</language>  <script>Latn</script>  <abstract format="text/plain" language="en" script="Latn">HTTP has been in use by the World-Wide Web global information initiative since 1990. This specification defines the protocol referred to as “HTTP/1.1”, and is an update to RFC 2068.  [STANDARDS-TRACK]</abstract>  <series type="main">    <title format="text/plain" language="en" script="Latn">RFC</title>    <number>2616</number>  </series>  <place>Fremont, CA</place></bibitem>
      </references></bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title depth="1" id="_">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <permission id="A" keep-with-next="true" keep-lines-together="true" model="default" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Permission</span>
                         <semx element="autonum" source="A">1</semx>
                         <span class="fmt-caption-delim">
                            :
                            <br/>
                         </span>
                         <semx element="identifier" source="A">/ogc/recommendation/wfs/2</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="A">1</semx>
                   </fmt-xref-label>
                   <identifier>/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <inherit id="_">
                      <eref type="inline" bibitemid="rfc2616" citeas="RFC 2616">RFC 2616 (HTTP/1.1)</eref>
                   </inherit>
                   <subject id="_">user</subject>
                   <subject id="_">non-user</subject>
                   <classification>
                      <tag id="_">control-class</tag>
                      <value id="_">Technical</value>
                   </classification>
                   <classification>
                      <tag id="_">priority</tag>
                      <value id="_">P0</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protection</value>
                   </classification>
                   <classification>
                      <tag id="_">family</tag>
                      <value id="_">System and Communications Protocols</value>
                   </classification>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
                   </description>
                   <specification exclude="true" type="tabular">
                      <p id="_">This is the object of the recommendation:</p>
                      <table id="_">
                         <tbody>
                            <tr>
                               <td style="text-align: left;">Object</td>
                               <td style="text-align: left;">Value</td>
                            </tr>
                            <tr>
                               <td style="text-align: left;">Mission</td>
                               <td style="text-align: left;">Accomplished</td>
                            </tr>
                         </tbody>
                      </table>
                   </specification>
                   <description id="_">
                      <p original-id="_">As for the measurement targets,</p>
                   </description>
                   <measurement-target exclude="false" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="1" original-id="C">
                         <body>CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </body>
                      </sourcecode>
                      <note autonum="1" original-id="N1">text</note>
                      <example autonum="1" original-id="E1">text</example>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="D" autonum="2">
                         <body>success-response()</body>
                      </sourcecode>
                   </import>
                   <component exclude="false" class="component1" id="_">
                      <p original-id="_">Hello</p>
                      <note autonum="2" original-id="N2">text</note>
                      <example autonum="2" original-id="E2">text</example>
                   </component>
                   <fmt-provision id="A" keep-with-next="true" keep-lines-together="true" model="default" autonum="1">
                      <p>
                         <em>
                            Subject:
                            <semx element="subject" source="_">user</semx>
                         </em>
                         <br/>
                         <em>
                            Subject:
                            <semx element="subject" source="_">non-user</semx>
                         </em>
                         <br/>
                         <em>
                            Inherits:
                            <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                         </em>
                         <br/>
                         <em>
                            Inherits:
                            <semx element="inherit" source="_">
                               <eref type="inline" bibitemid="rfc2616" citeas="RFC 2616" id="_">RFC 2616 (HTTP/1.1)</eref>
                               <semx element="eref" source="_">
                                  <fmt-xref type="inline" target="rfc2616">RFC 2616 (HTTP/1.1)</fmt-xref>
                               </semx>
                            </semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Control-class</semx>
                            :
                            <semx element="value" source="_">Technical</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Priority</semx>
                            :
                            <semx element="value" source="_">P0</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Family</semx>
                            :
                            <semx element="value" source="_">System and Communications Protection</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Family</semx>
                            :
                            <semx element="value" source="_">System and Communications Protocols</semx>
                         </em>
                      </p>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">
                               I recommend
                               <em>this</em>
                               .
                            </p>
                         </semx>
                      </div>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">As for the measurement targets,</p>
                         </semx>
                      </div>
                      <div type="requirement-measurement-target">
                         <semx element="measurement-target" source="_">
                            <p id="_">The measurement target shall be measured as:</p>
                            <formula id="B" autonum="1">
                               <fmt-name id="_">
                                  <span class="fmt-caption-label">
                                     <span class="fmt-autonum-delim">(</span>
                                     1
                                     <span class="fmt-autonum-delim">)</span>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <fmt-xref-label container="fwd">
                                  <span class="fmt-xref-container">
                                     <semx element="foreword" source="fwd">Foreword</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <stem type="AsciiMath" id="_">r/1 = 0</stem>
                               <fmt-stem type="AsciiMath">
                                  <semx element="stem" source="_">r/1 = 0</semx>
                               </fmt-stem>
                            </formula>
                         </semx>
                      </div>
                      <div type="requirement-verification">
                         <semx element="verification" source="_">
                            <p id="_">The following code will be run for verification:</p>
                            <sourcecode id="C" autonum="1">
                               <body>CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </body>
                               <fmt-sourcecode autonum="1" id="_">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </fmt-sourcecode>
                            </sourcecode>
                            <note id="N1" autonum="1">
                               <fmt-name id="_">
                                  <span class="fmt-caption-label">
                                     <span class="fmt-element-name">NOTE</span>
                                     <semx element="autonum" source="N1">1</semx>
                                  </span>
                                  <span class="fmt-label-delim">
                                     <tab/>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Note</span>
                                  <semx element="autonum" source="N1">1</semx>
                               </fmt-xref-label>
                               <fmt-xref-label container="A">
                                  <span class="fmt-xref-container">
                                     <span class="fmt-element-name">Permission</span>
                                     <semx element="autonum" source="A">1</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Note</span>
                                  <semx element="autonum" source="N1">1</semx>
                               </fmt-xref-label>
                               text
                            </note>
                            <example id="E1" autonum="1">
                               <fmt-name id="_">
                                  <span class="fmt-caption-label">
                                     <span class="fmt-element-name">EXAMPLE</span>
                                     <semx element="autonum" source="E1">1</semx>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Example</span>
                                  <semx element="autonum" source="E1">1</semx>
                               </fmt-xref-label>
                               <fmt-xref-label container="A">
                                  <span class="fmt-xref-container">
                                     <span class="fmt-element-name">Permission</span>
                                     <semx element="autonum" source="A">1</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Example</span>
                                  <semx element="autonum" source="E1">1</semx>
                               </fmt-xref-label>
                               text
                            </example>
                         </semx>
                      </div>
                      <div type="requirement-component1">
                         <semx element="component" source="_">
                            <p id="_">Hello</p>
                            <note id="N2" autonum="2">
                               <fmt-name id="_">
                                  <span class="fmt-caption-label">
                                     <span class="fmt-element-name">NOTE</span>
                                     <semx element="autonum" source="N2">2</semx>
                                  </span>
                                  <span class="fmt-label-delim">
                                     <tab/>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Note</span>
                                  <semx element="autonum" source="N2">2</semx>
                               </fmt-xref-label>
                               <fmt-xref-label container="A">
                                  <span class="fmt-xref-container">
                                     <span class="fmt-element-name">Permission</span>
                                     <semx element="autonum" source="A">1</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Note</span>
                                  <semx element="autonum" source="N2">2</semx>
                               </fmt-xref-label>
                               text
                            </note>
                            <example id="E2" autonum="2">
                               <fmt-name id="_">
                                  <span class="fmt-caption-label">
                                     <span class="fmt-element-name">EXAMPLE</span>
                                     <semx element="autonum" source="E2">2</semx>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Example</span>
                                  <semx element="autonum" source="E2">2</semx>
                               </fmt-xref-label>
                               <fmt-xref-label container="A">
                                  <span class="fmt-xref-container">
                                     <span class="fmt-element-name">Permission</span>
                                     <semx element="autonum" source="A">1</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Example</span>
                                  <semx element="autonum" source="E2">2</semx>
                               </fmt-xref-label>
                               text
                            </example>
                         </semx>
                      </div>
                   </fmt-provision>
                </permission>
             </foreword>
          </preface>
          <annex id="Annex" autonum="A" displayorder="3">
             <fmt-title id="_">
                <strong>
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Annex</span>
                      <semx element="autonum" source="Annex">A</semx>
                   </span>
                </strong>
                <br/>
                <span class="fmt-obligation">(informative)</span>
             </fmt-title>
             <fmt-xref-label>
                <span class="fmt-element-name">Annex</span>
                <semx element="autonum" source="Annex">A</semx>
             </fmt-xref-label>
             <permission id="AnnexPermission" model="default" autonum="A.1">
                <fmt-name id="_">
                   <span class="fmt-caption-label">
                      <span class="fmt-element-name">Permission</span>
                      <semx element="autonum" source="AnnexPermission">
                         <semx element="autonum" source="Annex">A</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="AnnexPermission">1</semx>
                      </semx>
                   </span>
                </fmt-name>
                <fmt-xref-label>
                   <span class="fmt-element-name">Permission</span>
                   <semx element="autonum" source="Annex">A</semx>
                   <span class="fmt-autonum-delim">.</span>
                   <semx element="autonum" source="AnnexPermission">1</semx>
                </fmt-xref-label>
                <description id="_">
                   <p original-id="_">As for the measurement targets,</p>
                   <note autonum="" original-id="N3">text</note>
                   <example autonum="" original-id="E3">text</example>
                </description>
                <fmt-provision id="AnnexPermission" model="default" autonum="A.1">
                   <div type="requirement-description">
                      <semx element="description" source="_">
                         <p id="_">As for the measurement targets,</p>
                         <note id="N3" autonum="">
                            <fmt-name id="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">NOTE</span>
                               </span>
                               <span class="fmt-label-delim">
                                  <tab/>
                               </span>
                            </fmt-name>
                            <fmt-xref-label>
                               <span class="fmt-element-name">Note</span>
                            </fmt-xref-label>
                            <fmt-xref-label container="AnnexPermission">
                               <span class="fmt-xref-container">
                                  <span class="fmt-element-name">Permission</span>
                                  <semx element="autonum" source="Annex">A</semx>
                                  <span class="fmt-autonum-delim">.</span>
                                  <semx element="autonum" source="AnnexPermission">1</semx>
                               </span>
                               <span class="fmt-comma">,</span>
                               <span class="fmt-element-name">Note</span>
                            </fmt-xref-label>
                            text
                         </note>
                         <example id="E3" autonum="">
                            <fmt-name id="_">
                               <span class="fmt-caption-label">
                                  <span class="fmt-element-name">EXAMPLE</span>
                               </span>
                            </fmt-name>
                            <fmt-xref-label>
                               <span class="fmt-element-name">Example</span>
                            </fmt-xref-label>
                            <fmt-xref-label container="AnnexPermission">
                               <span class="fmt-xref-container">
                                  <span class="fmt-element-name">Permission</span>
                                  <semx element="autonum" source="Annex">A</semx>
                                  <span class="fmt-autonum-delim">.</span>
                                  <semx element="autonum" source="AnnexPermission">1</semx>
                               </span>
                               <span class="fmt-comma">,</span>
                               <span class="fmt-element-name">Example</span>
                            </fmt-xref-label>
                            text
                         </example>
                      </semx>
                   </div>
                </fmt-provision>
             </permission>
          </annex>
          <bibliography>
             <references id="_bibliography" obligation="informative" normative="false" displayorder="4">
                <title id="_">Bibliography</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <bibitem id="rfc2616" type="standard">
                   <biblio-tag>
                      [1]
                      <tab/>
                      IETF\\u00a0RFC\\u00a02616,
                   </biblio-tag>
                   <formattedref>
                      R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE.
                      <em>Hypertext Transfer Protocol\\u2009—\\u2009HTTP/1.1</em>
                      . 1999. Fremont, CA.
                   </formattedref>
                   <fetched>2020-03-27</fetched>
                   <title format="text/plain" language="en" script="Latn">Hypertext Transfer Protocol\\u2009—\\u2009HTTP/1.1</title>
                   <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                   <docidentifier type="IETF">IETF\\u00a0RFC\\u00a02616</docidentifier>
                   <docidentifier type="IETF" scope="anchor">IETF\\u00a0RFC2616</docidentifier>
                   <docidentifier type="DOI">DOI\\u00a010.17487/RFC2616</docidentifier>
                   <docidentifier scope="biblio-tag">IETF\\u00a0RFC\\u00a02616</docidentifier>
                   <date type="published">
                      <on>1999-06</on>
                   </date>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">R. Fielding</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">J. Gettys</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">J. Mogul</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">H. Frystyk</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">L. Masinter</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">P. Leach</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <contributor>
                      <role type="author"/>
                      <person>
                         <name>
                            <completename language="en">T. Berners-Lee</completename>
                         </name>
                         <affiliation>
                            <organization>
                               <name>IETF</name>
                               <abbreviation>IETF</abbreviation>
                            </organization>
                         </affiliation>
                      </person>
                   </contributor>
                   <language>en</language>
                   <script>Latn</script>
                   <abstract format="text/plain" language="en" script="Latn">HTTP has been in use by the World-Wide Web global information initiative since 1990. This specification defines the protocol referred to as “HTTP/1.1”, and is an update to RFC 2068.  [STANDARDS-TRACK]</abstract>
                   <series type="main">
                      <title format="text/plain" language="en" script="Latn">RFC</title>
                      <number>2616</number>
                   </series>
                   <place>Fremont, CA</place>
                </bibitem>
             </references>
          </bibliography>
       </iso-standard>
    OUTPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                <br/>
                <div id="fwd">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <div class="permission" id="A" style="page-break-after: avoid;page-break-inside: avoid;">
                      <p class="RecommendationTitle">
                         Permission 1:
                         <br/>
                         /ogc/recommendation/wfs/2
                      </p>
                      <p>
                         <i>Subject: user</i>
                         <br/>
                         <i>Subject: non-user</i>
                         <br/>
                         <i>Inherits: /ss/584/2015/level/1</i>
                         <br/>
                         <i>
                            Inherits:
                            <a href="#rfc2616">RFC 2616 (HTTP/1.1)</a>
                         </i>
                         <br/>
                         <i>Control-class: Technical</i>
                         <br/>
                         <i>Priority: P0</i>
                         <br/>
                         <i>Family: System and Communications Protection</i>
                         <br/>
                         <i>Family: System and Communications Protocols</i>
                      </p>
                      <div class="requirement-description">
                         <p id="_">
                            I recommend
                            <i>this</i>
                            .
                         </p>
                      </div>
                      <div class="requirement-description">
                         <p id="_">As for the measurement targets,</p>
                      </div>
                      <div class="requirement-measurement-target">
                         <p id="_">The measurement target shall be measured as:</p>
                         <div id="B">
                            <div class="formula">
                               <p>
                                  <span class="stem">(#(r/1 = 0)#)</span>
                                  \\u00a0 (1)
                               </p>
                            </div>
                         </div>
                      </div>
                      <div class="requirement-verification">
                         <p id="_">The following code will be run for verification:</p>
                         <pre id="C" class="sourcecode">
                            CoreRoot(success): HttpResponse
                            <br/>
                            \\u00a0\\u00a0\\u00a0\\u00a0\\u00a0 if (success)
                            <br/>
                            \\u00a0\\u00a0\\u00a0\\u00a0\\u00a0 recommendation(label: success-response)
                            <br/>
                            \\u00a0\\u00a0\\u00a0\\u00a0\\u00a0 end
                            <br/>
                            \\u00a0\\u00a0\\u00a0
                         </pre>
                         <div id="N1" class="Note">
                            <p>
                               <span class="note_label">NOTE 1\\u00a0 </span>
                            </p>
                            text
                         </div>
                         <div id="E1" class="example">
                            <p class="example-title">EXAMPLE 1</p>
                            text
                         </div>
                      </div>
                      <div class="requirement-component1">
                         <p id="_">Hello</p>
                         <div id="N2" class="Note">
                            <p>
                               <span class="note_label">NOTE 2\\u00a0 </span>
                            </p>
                            text
                         </div>
                         <div id="E2" class="example">
                            <p class="example-title">EXAMPLE 2</p>
                            text
                         </div>
                      </div>
                   </div>
                </div>
                <br/>
                <div id="Annex" class="Section3">
                   <h1 class="Annex">
                      <b>Annex A</b>
                      <br/>
                      (informative)
                   </h1>
                   <div class="permission" id="AnnexPermission">
                      <p class="RecommendationTitle">Permission A.1</p>
                      <div class="requirement-description">
                         <p id="_">As for the measurement targets,</p>
                         <div id="N3" class="Note">
                            <p>
                               <span class="note_label">NOTE\\u00a0 </span>
                            </p>
                            text
                         </div>
                         <div id="E3" class="example">
                            <p class="example-title">EXAMPLE</p>
                            text
                         </div>
                      </div>
                   </div>
                </div>
                <br/>
                <div>
                   <h1 class="Section3">Bibliography</h1>
                   <p id="rfc2616" class="Biblio">
                      [1]\\u00a0 IETF\\u00a0RFC\\u00a02616, R. FIELDING, J. GETTYS, J. MOGUL, H. FRYSTYK, L. MASINTER, P. LEACH and T. BERNERS-LEE.
                      <i>Hypertext Transfer Protocol\\u2009—\\u2009HTTP/1.1</i>
                      . 1999. Fremont, CA.
                   </p>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes requirements" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
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
          <sourcecode id="C"><body>CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </body></sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="D"><body>success-response()</body></sourcecode>
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
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <requirement id="A" unnumbered="true" keep-with-next="true" keep-lines-together="true" model="default">
                   <title>A New Requirement</title>
                   <identifier>/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <subject id="_">user</subject>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
                   </description>
                   <specification exclude="true" type="tabular">
                      <p id="_">This is the object of the recommendation:</p>
                      <table id="_">
                         <tbody>
                            <tr>
                               <td style="text-align: left;">Object</td>
                               <td style="text-align: left;">Value</td>
                            </tr>
                            <tr>
                               <td style="text-align: left;">Mission</td>
                               <td style="text-align: left;">Accomplished</td>
                            </tr>
                         </tbody>
                      </table>
                   </specification>
                   <description id="_">
                      <p original-id="_">As for the measurement targets,</p>
                   </description>
                   <measurement-target exclude="false" keep-with-next="true" keep-lines-together="true" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="1" original-id="C"><body>CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </body></sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="D" autonum="2"><body>success-response()</body></sourcecode>
                   </import>
                   <component exclude="false" class="component1" id="_">
                      <p original-id="_">Hello</p>
                   </component>
                   <fmt-provision id="A" unnumbered="true" keep-with-next="true" keep-lines-together="true" model="default">
                      <p>
                         <em>
                            Subject:
                            <semx element="subject" source="_">user</semx>
                         </em>
                         <br/>
                         <em>
                            Inherits:
                            <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                         </em>
                      </p>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">
                               I recommend
                               <em>this</em>
                               .
                            </p>
                         </semx>
                      </div>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">As for the measurement targets,</p>
                         </semx>
                      </div>
                      <div keep-with-next="true" keep-lines-together="true" type="requirement-measurement-target">
                         <semx element="measurement-target" source="_">
                            <p id="_">The measurement target shall be measured as:</p>
                            <formula id="B" autonum="1">
                               <fmt-name id="_">
                                  <span class="fmt-caption-label">
                                     <span class="fmt-autonum-delim">(</span>
                                     1
                                     <span class="fmt-autonum-delim">)</span>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <fmt-xref-label container="fwd">
                                  <span class="fmt-xref-container">
                                     <semx element="foreword" source="fwd">Foreword</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <stem type="AsciiMath" id="_">r/1 = 0</stem>
                               <fmt-stem type="AsciiMath">
                                  <semx element="stem" source="_">r/1 = 0</semx>
                               </fmt-stem>
                            </formula>
                         </semx>
                      </div>
                      <div type="requirement-verification">
                         <semx element="verification" source="_">
                            <p id="_">The following code will be run for verification:</p>
                            <sourcecode id="C" autonum="1"><body>
                               CoreRoot(success): HttpResponse if (success) recommendation(label: success-response) end
                               </body><fmt-sourcecode id="_" autonum="1">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </fmt-sourcecode>
                            </sourcecode>
                         </semx>
                      </div>
                      <div type="requirement-component1">
                         <semx element="component" source="_">
                            <p id="_">Hello</p>
                         </semx>
                      </div>
                   </fmt-provision>
                </requirement>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT

    output = <<~OUTPUT
      #{HTML_HDR}
                        <br/>
                      <div id="fwd">
                        <h1 class="ForewordTitle">Foreword</h1>
                        <div class="require" id='A' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p><i>Subject: user</i><br/><i>Inherits: /ss/584/2015/level/1</i></p>
                  <div class="requirement-description">
                    <p id="_">I recommend <i>this</i>.</p>
                  </div>
                  <div class="requirement-description">
                    <p id="_">As for the measurement targets,</p>
                  </div>
                  <div class="requirement-measurement-target"  style='page-break-after: avoid;page-break-inside: avoid;'>
                    <p id="_">The measurement target shall be measured as:</p>
                    <div id="B"><div class="formula"><p><span class="stem">(#(r/1 = 0)#)</span> \\u00a0 (1)</p></div></div>
                  </div>
                  <div class="requirement-verification">
                    <p id="_">The following code will be run for verification:</p>
                    <pre id="C" class="sourcecode">CoreRoot(success): HttpResponse<br/>\\u00a0\\u00a0\\u00a0\\u00a0\\u00a0 if (success)<br/>\\u00a0\\u00a0\\u00a0\\u00a0\\u00a0 recommendation(label: success-response)<br/>\\u00a0\\u00a0\\u00a0\\u00a0\\u00a0 end<br/>\\u00a0\\u00a0\\u00a0 </pre>
                  </div>
              <div class='requirement-component1'> <p id='_'>Hello</p> </div>
                </div>
                      </div>
                    </div>
                  </body>
                </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes recommendation" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword id="fwd">
          <recommendation id="A" obligation="shall,could"   keep-with-next="true" keep-lines-together="true" model="default">
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
          <formula id="B">
            <stem type="AsciiMath">r/1 = 0</stem>
          </formula>
        </measurement-target>
        <verification exclude="false">
          <p id="_">The following code will be run for verification:</p>
          <sourcecode id="C"><body>CoreRoot(success): HttpResponse
            if (success)
            recommendation(label: success-response)
            end
          </body></sourcecode>
        </verification>
        <import exclude="true">
          <sourcecode id="D"><body>success-response()</body></sourcecode>
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
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
             <foreword id="fwd" displayorder="2">
                <title id="_">Foreword</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <recommendation id="A" obligation="shall,could" keep-with-next="true" keep-lines-together="true" model="default" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">Recommendation</span>
                         <semx element="autonum" source="A">1</semx>
                         <span class="fmt-caption-delim">
                            :
                            <br/>
                         </span>
                         <semx element="identifier" source="A">/ogc/recommendation/wfs/2</semx>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Recommendation</span>
                      <semx element="autonum" source="A">1</semx>
                   </fmt-xref-label>
                   <identifier>/ogc/recommendation/wfs/2</identifier>
                   <inherit id="_">/ss/584/2015/level/1</inherit>
                   <classification>
                      <tag id="_">type</tag>
                      <value id="_">text</value>
                   </classification>
                   <classification>
                      <tag id="_">language</tag>
                      <value id="_">BASIC</value>
                   </classification>
                   <subject id="_">user</subject>
                   <description id="_">
                      <p original-id="_">
                         I recommend
                         <em>this</em>
                         .
                      </p>
                   </description>
                   <specification exclude="true" type="tabular">
                      <p id="_">This is the object of the recommendation:</p>
                      <table id="_">
                         <tbody>
                            <tr>
                               <td style="text-align: left;">Object</td>
                               <td style="text-align: left;">Value</td>
                            </tr>
                            <tr>
                               <td style="text-align: left;">Mission</td>
                               <td style="text-align: left;">Accomplished</td>
                            </tr>
                         </tbody>
                      </table>
                   </specification>
                   <description id="_">
                      <p original-id="_">As for the measurement targets,</p>
                   </description>
                   <measurement-target exclude="false" id="_">
                      <p original-id="_">The measurement target shall be measured as:</p>
                      <formula autonum="1" original-id="B">
                         <stem type="AsciiMath">r/1 = 0</stem>
                      </formula>
                   </measurement-target>
                   <verification exclude="false" id="_">
                      <p original-id="_">The following code will be run for verification:</p>
                      <sourcecode autonum="1" original-id="C"><body>CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </body></sourcecode>
                   </verification>
                   <import exclude="true">
                      <sourcecode id="D" autonum="2"><body>success-response()</body></sourcecode>
                   </import>
                   <component exclude="false" class="component1" id="_">
                      <p original-id="_">Hello</p>
                   </component>
                   <fmt-provision id="A" obligation="shall,could" keep-with-next="true" keep-lines-together="true" model="default" autonum="1">
                      <p>
                         <em>Obligation: shall,could</em>
                         <br/>
                         <em>
                            Subject:
                            <semx element="subject" source="_">user</semx>
                         </em>
                         <br/>
                         <em>
                            Inherits:
                            <semx element="inherit" source="_">/ss/584/2015/level/1</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Type</semx>
                            :
                            <semx element="value" source="_">text</semx>
                         </em>
                         <br/>
                         <em>
                            <semx element="tag" source="_">Language</semx>
                            :
                            <semx element="value" source="_">BASIC</semx>
                         </em>
                      </p>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">
                               I recommend
                               <em>this</em>
                               .
                            </p>
                         </semx>
                      </div>
                      <div type="requirement-description">
                         <semx element="description" source="_">
                            <p id="_">As for the measurement targets,</p>
                         </semx>
                      </div>
                      <div type="requirement-measurement-target">
                         <semx element="measurement-target" source="_">
                            <p id="_">The measurement target shall be measured as:</p>
                            <formula id="B" autonum="1">
                               <fmt-name id="_">
                                  <span class="fmt-caption-label">
                                     <span class="fmt-autonum-delim">(</span>
                                     1
                                     <span class="fmt-autonum-delim">)</span>
                                  </span>
                               </fmt-name>
                               <fmt-xref-label>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <fmt-xref-label container="fwd">
                                  <span class="fmt-xref-container">
                                     <semx element="foreword" source="fwd">Foreword</semx>
                                  </span>
                                  <span class="fmt-comma">,</span>
                                  <span class="fmt-element-name">Formula</span>
                                  <span class="fmt-autonum-delim">(</span>
                                  <semx element="autonum" source="B">1</semx>
                                  <span class="fmt-autonum-delim">)</span>
                               </fmt-xref-label>
                               <stem type="AsciiMath" id="_">r/1 = 0</stem>
                               <fmt-stem type="AsciiMath">
                                  <semx element="stem" source="_">r/1 = 0</semx>
                               </fmt-stem>
                            </formula>
                         </semx>
                      </div>
                      <div type="requirement-verification">
                         <semx element="verification" source="_">
                            <p id="_">The following code will be run for verification:</p>
                            <sourcecode id="C" autonum="1"><body>
                               CoreRoot(success): HttpResponse if (success) recommendation(label: success-response) end
                               </body><fmt-sourcecode id="_" autonum="1">CoreRoot(success): HttpResponse
             if (success)
             recommendation(label: success-response)
             end
           </fmt-sourcecode>
                            </sourcecode>
                         </semx>
                      </div>
                      <div type="requirement-component1">
                         <semx element="component" source="_">
                            <p id="_">Hello</p>
                         </semx>
                      </div>
                   </fmt-provision>
                </recommendation>
             </foreword>
          </preface>
       </iso-standard>
    OUTPUT

    output = <<~OUTPUT
      #{HTML_HDR}
                       <br/>
                      <div id="fwd">
                        <h1 class="ForewordTitle">Foreword</h1>
                <div class="recommend"  id='A' style='page-break-after: avoid;page-break-inside: avoid;'>
                <p class="RecommendationTitle">Recommendation 1:<br/>/ogc/recommendation/wfs/2</p><p><i>Obligation: shall,could</i><br/><i>Subject: user</i><br/><i>Inherits: /ss/584/2015/level/1</i><br/><i>Type: text</i><br/><i>Language: BASIC</i></p>
                  <div class="requirement-description">
                    <p id="_">I recommend <i>this</i>.</p>
                  </div>
                  <div class="requirement-description">
                    <p id="_">As for the measurement targets,</p>
                  </div>
                  <div class="requirement-measurement-target">
                    <p id="_">The measurement target shall be measured as:</p>
                    <div id="B"><div class="formula"><p><span class="stem">(#(r/1 = 0)#)</span>\\u00a0 (1)</p></div></div>
                  </div>
                  <div class="requirement-verification">
                    <p id="_">The following code will be run for verification:</p>
                    <pre id="C" class="sourcecode">CoreRoot(success): HttpResponse<br/>\\u00a0\\u00a0\\u00a0\\u00a0\\u00a0 if (success)<br/>\\u00a0\\u00a0\\u00a0\\u00a0\\u00a0 recommendation(label: success-response)<br/>\\u00a0\\u00a0\\u00a0\\u00a0\\u00a0 end<br/>\\u00a0\\u00a0\\u00a0 </pre>
                  </div>
                          <div class='requirement-component1'> <p id='_'>Hello</p> </div>
                </div>
                      </div>
                    </div>
                  </body>
                </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
