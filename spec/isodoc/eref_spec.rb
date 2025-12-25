require "spec_helper"

RSpec.describe IsoDoc do
  it "processes links" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface> <clause type="toc" id="_" displayorder="1">
        <fmt-title id="_" depth="1">Table of contents</fmt-title>
      </clause>
      <foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
        <p>
        <link target="http://example.com"/>
        <link style="fred" target="http://example.com"/>
        <link target="http://example.com"><br/></link>
        <link target="http://example.com">example</link>
        <link target="http://example.com" alt="tip">example</link>
        <link target="mailto:fred@example.com"/>
        <link target="mailto:fred@example.com">mailto:fred@example.com</link>
        <link target="https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512"/>
        </p>
        </foreword></preface>
        <sections>
        </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <foreword displayorder="1" id="_">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">Foreword</fmt-title>
               <p>
                  <link target="http://example.com" id="_"/>
                    <semx element="link" source="_">
                      <fmt-link target="http://example.com"/>
                    </semx>
                  <link style="fred" target="http://example.com" id="_"/>
                  <semx element="link" source="_">
                     <fmt-link style="fred" target="http://example.com"/>
                  </semx>
                  <link target="http://example.com" id="_">
                     <br/>
                  </link>
                  <semx element="link" source="_">
                     <fmt-link target="http://example.com">
                        <br/>
                     </fmt-link>
                  </semx>
                  <link target="http://example.com" id="_">example</link>
                  <semx element="link" source="_">
                     <fmt-link target="http://example.com">example</fmt-link>
                  </semx>
                  <link target="http://example.com" alt="tip" id="_">example</link>
                  <semx element="link" source="_">
                     <fmt-link target="http://example.com" alt="tip">example</fmt-link>
                  </semx>
                  <link target="mailto:fred@example.com" id="_"/>
                  <semx element="link" source="_">
                     <fmt-link target="mailto:fred@example.com"/>
                  </semx>
                  <link target="mailto:fred@example.com" id="_">mailto:fred@example.com</link>
                  <semx element="link" source="_">
                     <fmt-link target="mailto:fred@example.com">mailto:fred@example.com</fmt-link>
                  </semx>
                  <link target="https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512" id="_"/>
                  <semx element="link" source="_">
                     <fmt-link target="https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512"/>
                  </semx>
               </p>
            </foreword>
            <clause type="toc" id="_" displayorder="2">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
         </preface>
         <sections>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR}
                 <br/>
                 <div id="_">
                   <h1 class="ForewordTitle">Foreword</h1>
                   <p>
         <a href="http://example.com">http://example.com</a>
         <a href="http://example.com" class="fred">http://example.com</a>
         <a href="http://example.com"><br/></a>
         <a href="http://example.com">example</a>
         <a href="http://example.com" title="tip">example</a>
         <a href="mailto:fred@example.com">fred@example.com</a>
         <a href="mailto:fred@example.com">mailto:fred@example.com</a>
         <a href="https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512">https://maps.gnosis.earth/ogcapi/collections/sentinel2-l2a/map?center=0,51.5&amp;scale-denominator=50000&amp;datetime=2022-04-01&amp;width=1024&amp;height=512</a>
         </p>
                 </div>
               </div>
             </body>
         </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes updatetype links" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword id="_" displayorder="2"><fmt-title id="_">Foreword</fmt-title>
      <p>
      <fmt-link update-type="true" target="http://example.com"/>
      <fmt-link update-type="true" target="list.adoc">example</fmt-link>
      <fmt-link update-type="true" target="list" alt="tip">example</fmt-link>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <p>
      <a href="http://example.com">http://example.com</a>
      <a href='list.adoc'>example</a>
      <a href='list.html' title='tip'>example</a>
      </p>
              </div>
    OUTPUT
    doc = <<~OUTPUT
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <p>
      <a href="http://example.com">http://example.com</a>
      <a href='list.adoc'>example</a>
      <a href='list.doc' title='tip'>example</a>
      </p>
              </div>
    OUTPUT
    expect(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))
      .sub(/^.*<h1/m, "<div><h1").sub(%r{</div>.*$}m, "</div>"))
      .to be_equivalent_to Canon.format_xml(html)
    expect(Canon.format_xml(IsoDoc::WordConvert.new({})
      .convert("test", input, true))
      .sub(/^.*<h1/m, "<div><h1").sub(%r{</div>.*$}m, "</div>"))
      .to be_equivalent_to Canon.format_xml(doc)
  end

  it "processes eref types" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
          <eref type="footnote" bibitemid="ISO713" citeas="ISO 713">A</eref>
          <eref type="inline" bibitemid="ISO713" citeas="ISO 713">A</eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <formattedref format="text/plain"><em>Cereals and cereal products</em></formattedref>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
            <bibitem id="ISO713" type="standard">
        <formattedref format="text/plain"><em>Cereals and cereal products</em></formattedref>
        <docidentifier>ISO 713</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <uri type="citation">http://wwww.example.com</uri>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword id="_" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p>
            <eref type="footnote" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
            <semx element="eref" source="_">
               <sup>
                  <fmt-xref type="footnote" target="ISO712">A</fmt-xref>
               </sup>
            </semx>
            <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
            <semx element="eref" source="_">
               <fmt-xref type="inline" target="ISO712">A</fmt-xref>
            </semx>
            <eref type="footnote" bibitemid="ISO713" citeas="ISO 713" id="_">A</eref>
            <semx element="eref" source="_">
               <sup>
                  <fmt-link target="http://wwww.example.com">A</fmt-link>
               </sup>
            </semx>
            <eref type="inline" bibitemid="ISO713" citeas="ISO 713" id="_">A</eref>
            <semx element="eref" source="_">
               <fmt-link target="http://wwww.example.com">A</fmt-link>
            </semx>
         </p>
      </foreword>
    OUTPUT
    html = <<~OUTPUT
      #{HTML_HDR}
             <br/>
             <div id="_">
               <h1 class='ForewordTitle'>Foreword</h1>
                              <p>
                 <sup>
                   <a href="#ISO712">A</a>
                 </sup>
                 <a href="#ISO712">A</a>
                 <sup>
                   <a href="http://wwww.example.com">A</a>
                 </sup>
                 <a href="http://wwww.example.com">A</a>
               </p>
             </div>
             <div>
               <h1>1.\\u00a0 Normative References</h1>
               <p id="ISO712" class="NormRef">ISO\\u00a0712,
                 <i>Cereals and cereal products</i>
               </p>
               <p id="ISO713" class="NormRef">ISO\\u00a0713,
                 <i>Cereals and cereal products</i>
               </p>
             </div>
           </div>
         </body>
       </html>
    OUTPUT
    output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", output, true))))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "processes eref styles" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p><eref type="inline" style="author_date" bibitemid="ISO712" citeas="ISO 712"/></p>
          <p><eref type="inline" style="author_date_br" bibitemid="ISO712" citeas="ISO 712"/></p>
          <p><eref type="inline" style="reference_tag" bibitemid="ISO712" citeas="ISO 712"/></p>
          <p><eref type="inline" style="title" bibitemid="ISO712" citeas="ISO 712"/></p>
          <p><eref type="inline" style="title_reference_tag" bibitemid="ISO712" citeas="ISO 712"/></p>
          <p><eref type="inline" style="short" bibitemid="ISO712" citeas="ISO 712"/></p>
          <p><eref type="inline" style="full" bibitemid="ISO712" citeas="ISO 712"/></p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="book">
              <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
              <uri type="src">https://www.iso.org/standard/4766.html</uri>
              <uri type="citation">http://www.example.com</uri>
              <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
              <docidentifier type="ISBN">9781108877831</docidentifier>
              <docidentifier scope="biblio-tag">[1]</docidentifier>
              <date type="published"><on>2022</on></date>
              <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Aluffi</surname><forename>Paolo</forename></name>
                </person>
              </contributor>
                      <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Anderson</surname><forename>David</forename></name>
                </person>
              </contributor>
              <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Hering</surname><forename>Milena</forename></name>
                </person>
              </contributor>
              <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
                </person>
              </contributor>
              <contributor>
                <role type="editor"/>
                <person>
                  <name><surname>Payne</surname><forename>Sam</forename></name>
                </person>
              </contributor>
              <edition>1</edition>
              <series>
              <title>London Mathematical Society Lecture Note Series</title>
              <number>472</number>
              </series>
                  <contributor>
                    <role type="publisher"/>
                    <organization>
                      <name>Cambridge University Press</name>
                    </organization>
                  </contributor>
                  <place>Cambridge, UK</place>
                <size><value type="volume">1</value></size>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword id="_" displayorder="2">
         <title id="_">Foreword</title>
         <fmt-title depth="1" id="_">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
         <p>
            <eref type="inline" style="author_date" bibitemid="ISO712" citeas="ISO 712" id="_"/>
            <semx element="eref" source="_">
               <fmt-link target="http://www.example.com">Aluffi, Anderson, Hering, Mustaţă and Payne 2022</fmt-link>
            </semx>
         </p>
         <p>
            <eref type="inline" style="author_date_br" bibitemid="ISO712" citeas="ISO 712" id="_"/>
            <semx element="eref" source="_">
               <fmt-link target="http://www.example.com">Aluffi, Anderson, Hering, Mustaţă and Payne (2022)</fmt-link>
            </semx>
         </p>
         <p>
            <eref type="inline" style="reference_tag" bibitemid="ISO712" citeas="ISO 712" id="_"/>
            <semx element="eref" source="_">
               <fmt-link target="http://www.example.com">[1]</fmt-link>
            </semx>
         </p>
         <p>
            <eref type="inline" style="title" bibitemid="ISO712" citeas="ISO 712" id="_"/>
            <semx element="eref" source="_">
               <fmt-link target="http://www.example.com">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</fmt-link>
            </semx>
         </p>
         <p>
            <eref type="inline" style="title_reference_tag" bibitemid="ISO712" citeas="ISO 712" id="_"/>
            <semx element="eref" source="_">
               <fmt-link target="http://www.example.com">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday [1]</fmt-link>
            </semx>
         </p>
         <p>
            <eref type="inline" style="short" bibitemid="ISO712" citeas="ISO 712" id="_"/>
            <semx element="eref" source="_">
                            <fmt-eref type="inline" style="short" bibitemid="ISO712" citeas="1">
                   <fmt-xref target="ISO712">ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.)</fmt-xref>
                   .
                  <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>
                  . First edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. [1]. DOI: DOI\\u00a0https://doi.org/10.1017/9781108877831. ISBN: ISBN\\u00a09781108877831. 1 vol.
               </fmt-eref>
            </semx>
         </p>
         <p>
            <eref type="inline" style="full" bibitemid="ISO712" citeas="ISO 712" id="_"/>
            <semx element="eref" source="_">
               <fmt-xref type="inline" style="full" target="ISO712">
                  ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.).
                  <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>
                  . First edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. [1]. DOI: DOI\\u00a0https://doi.org/10.1017/9781108877831. ISBN: ISBN\\u00a09781108877831.
                  <fmt-link target="http://www.example.com">http://www.example.com</fmt-link>
                  . 1 vol.
               </fmt-xref>
            </semx>
         </p>
      </foreword>
    OUTPUT
    html = <<~OUTPUT
         <html lang="en">
         <head/>
         <body lang="en">
            <div class="title-section">
               <p>\\u00a0</p>
            </div>
            <br/>
            <div class="prefatory-section">
               <p>\\u00a0</p>
            </div>
            <br/>
            <div class="main-section">
               <br/>
               <div id="_" class="TOC">
                  <h1 class="IntroTitle">Table of contents</h1>
               </div>
               <br/>
               <div id="_">
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p>
                     <a href="http://www.example.com">Aluffi, Anderson, Hering, Mustaţă and Payne 2022</a>
                  </p>
                  <p>
                     <a href="http://www.example.com">Aluffi, Anderson, Hering, Mustaţă and Payne (2022)</a>
                  </p>
                  <p>
                     <a href="http://www.example.com">[1]</a>
                  </p>
                  <p>
                     <a href="http://www.example.com">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</a>
                  </p>
                  <p>
                     <a href="http://www.example.com">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday [1]</a>
                  </p>
                                     <p>
                     <a href="#ISO712">ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.)</a>.
                     <i>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</i>
                     . First edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. [1]. DOI: DOI\\u00a0https://doi.org/10.1017/9781108877831. ISBN: ISBN\\u00a09781108877831. 1 vol.
                  </p>
                  <p>
                     ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.).
                     <i>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</i>
                     . First edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. [1]. DOI: DOI\\u00a0https://doi.org/10.1017/9781108877831. ISBN: ISBN\\u00a09781108877831.
                     <a href="http://www.example.com">http://www.example.com</a>
                     . 1 vol.
                  </p>
               </div>
               <div>
                  <h1>1.\\u00a0 Normative References</h1>
                  <p id="ISO712" class="NormRef">
                     1, ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.).
                     <i>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</i>
                     . First edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. [1]. DOI: DOI\\u00a0https://doi.org/10.1017/9781108877831. ISBN: ISBN\\u00a09781108877831.
                     <a href="http://www.example.com">http://www.example.com</a>
                     . 1 vol.
                  </p>
               </div>
            </div>
         </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(pres_output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "processes eref content" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p id="A">
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
          <eref type="inline" bibitemid="ISO712"/>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality><display-text>A</display-text></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="whole"></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="locality:URI"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><display-text>A</display-text></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" droploc="true" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" case="lowercase" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <p id="A">
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_"/>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="table">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Table 1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <localityStack connective="and">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </localityStack>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Table 1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <localityStack connective="and">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </localityStack>
             <localityStack connective="and">
                <locality type="clause">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </localityStack>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">
                ISO\\u00a0712, Table 1
                <span class="fmt-conn">and</span>
                Clause 1
             </fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="table">
                <referenceFrom>1</referenceFrom>
                <referenceTo>1</referenceTo>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Table 1–1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
             <locality type="table">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Clause 1, Table 1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Clause 1</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="clause">
                <referenceFrom>1.5</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Clause 1.5</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="table">
                <referenceFrom>1</referenceFrom>
             </locality>
             A
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">A</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="whole"/>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Whole of text</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="locality:prelude">
                <referenceFrom>7</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Prelude 7</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="locality:URI">
                <referenceFrom>7</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, URI 7</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_">A</eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">A</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="anchor">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712</fmt-xref>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_">
             <locality type="anchor">
                <referenceFrom>1</referenceFrom>
             </locality>
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" target="ISO712">ISO\\u00a0712, Clause 1</fmt-xref>
          </semx>
          <eref type="inline" droploc="true" bibitemid="ISO712" id="_">
             <locality type="anchor">
                <referenceFrom>1</referenceFrom>
             </locality>
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" droploc="true" target="ISO712">ISO\\u00a0712, 1</fmt-xref>
          </semx>
          <eref type="inline" case="lowercase" bibitemid="ISO712" id="_">
             <locality type="anchor">
                <referenceFrom>1</referenceFrom>
             </locality>
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-xref type="inline" case="lowercase" target="ISO712">ISO\\u00a0712, clause 1</fmt-xref>
          </semx>
       </p>
    OUTPUT

    html = <<~OUTPUT
            <p id="A">
      <a href="#ISO712">ISO\\u00a0712</a>
      <a href="#ISO712">ISO\\u00a0712</a>
      <a href="#ISO712">ISO\\u00a0712, Table 1</a>
      <a href='#ISO712'>ISO\\u00a0712, Table 1</a>
      <a href="#ISO712">ISO\\u00a0712, Table 1 and Clause 1</a>
      <a href="#ISO712">ISO\\u00a0712, Table 1&#8211;1</a>
      <a href="#ISO712">ISO\\u00a0712, Clause 1, Table 1</a>
      <a href="#ISO712">ISO\\u00a0712, Clause 1</a>
      <a href="#ISO712">ISO\\u00a0712, Clause 1.5</a>
      <a href="#ISO712">A</a>
      <a href="#ISO712">ISO\\u00a0712, Whole of text</a>
      <a href="#ISO712">ISO\\u00a0712, Prelude 7</a>
      <a href="#ISO712">ISO\\u00a0712, URI 7</a>
      <a href="#ISO712">A</a>
      <a href='#ISO712'>ISO\\u00a0712</a>
      <a href='#ISO712'>ISO\\u00a0712, Clause 1</a>
      <a href='#ISO712'>ISO\\u00a0712, 1</a>
      <a href='#ISO712'>ISO\\u00a0712, clause 1</a>
      </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "processes eref content pointing to reference with citation URL" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>fr</language>
          </bibdata>
          <preface><foreword>
          <p>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
          <eref type="inline" bibitemid="ISO712"/>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO713"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom></locality>A</eref>
          <eref type="inline" bibitemid="ISO713"><locality type="whole"></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713" citeas="ISO 713">A</eref>
          <eref type="inline" bibitemid="ISO713"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO714"/>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="citation">https://www.google.com</uri>
        <uri type="citation" language="en">https://www.google.com/en</uri>
        <uri type="citation" language="fr">https://www.google.com/fr</uri>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO713" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="citation">spec/assets/iso713</uri>
        <uri type="citation">spec/assets/iso714</uri>
        <docidentifier>ISO 713</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO714" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="citation">spec/assets/iso714.svg</uri>
        <docidentifier>ISO 714</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword id="_" displayorder="2">
          <title id="_">Avant-propos</title>
          <fmt-title id="_" depth="1">
             <semx element="title" source="_">Avant-propos</semx>
          </fmt-title>
          <p>
             <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
             <semx element="eref" source="_">
                <fmt-link target="https://www.google.com/fr">ISO\\u00a0712</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO712" id="_"/>
             <semx element="eref" source="_">
                <fmt-link target="https://www.google.com/fr">ISO\\u00a0712</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <localityStack connective="and">
                   <locality type="table">
                      <referenceFrom>1</referenceFrom>
                   </locality>
                </localityStack>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <localityStack connective="and">
                   <locality type="table">
                      <referenceFrom>1</referenceFrom>
                   </locality>
                </localityStack>
                <localityStack connective="and">
                   <locality type="clause">
                      <referenceFrom>1</referenceFrom>
                   </locality>
                </localityStack>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">
                   ISO\\u00a0713, Tableau 1
                   <span class="fmt-conn">et</span>
                   Article 1
                </fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                   <referenceTo>1</referenceTo>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1–1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="clause">
                   <referenceFrom>1</referenceFrom>
                </locality>
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO\\u00a0713, Article 1, Tableau 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="clause">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO\\u00a0713, Article 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="clause">
                   <referenceFrom>1.5</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO\\u00a0713, Article 1.5</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
                A
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">A</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="whole"/>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO\\u00a0713, Ensemble du texte</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="locality:prelude">
                   <referenceFrom>7</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">ISO\\u00a0713, Prelude 7</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" citeas="ISO 713" id="_">A</eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html">A</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="anchor">
                   <referenceFrom>xyz</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html#xyz">ISO\\u00a0713</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO713" id="_">
                <locality type="anchor">
                   <referenceFrom>xyz</referenceFrom>
                </locality>
                <locality type="clause">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </eref>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso713.html#xyz">ISO\\u00a0713, Article 1</fmt-link>
             </semx>
             <eref type="inline" bibitemid="ISO714" id="_"/>
             <semx element="eref" source="_">
                <fmt-link target="spec/assets/iso714.svg">ISO\\u00a0714</fmt-link>
             </semx>
          </p>
       </foreword>
    OUTPUT

    html = <<~OUTPUT
      <div id="_">
         <h1 class="ForewordTitle">Avant-propos</h1>
         <p>
            <a href="https://www.google.com/fr">ISO\\u00a0712</a>
            <a href="https://www.google.com/fr">ISO\\u00a0712</a>
            <a href="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1</a>
            <a href="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1</a>
            <a href="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1 et Article 1</a>
            <a href="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1–1</a>
            <a href="spec/assets/iso713.html">ISO\\u00a0713, Article 1, Tableau 1</a>
            <a href="spec/assets/iso713.html">ISO\\u00a0713, Article 1</a>
            <a href="spec/assets/iso713.html">ISO\\u00a0713, Article 1.5</a>
            <a href="spec/assets/iso713.html">A</a>
            <a href="spec/assets/iso713.html">ISO\\u00a0713, Ensemble du texte</a>
            <a href="spec/assets/iso713.html">ISO\\u00a0713, Prelude 7</a>
            <a href="spec/assets/iso713.html">A</a>
            <a href="spec/assets/iso713.html#xyz">ISO\\u00a0713</a>
            <a href="spec/assets/iso713.html#xyz">ISO\\u00a0713, Article 1</a>
            <a href="spec/assets/iso714.svg">ISO\\u00a0714</a>
         </p>
      </div>
    OUTPUT

    word = <<~OUTPUT
      <div id="_">
         <h1 class="ForewordTitle">Avant-propos</h1>
         <p>
           <a href="https://www.google.com/fr">ISO\\u00a0712</a>
           <a href="https://www.google.com/fr">ISO\\u00a0712</a>
           <a href="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1</a>
           <a href="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1</a>
           <a href="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1 et Article 1</a>
           <a href="spec/assets/iso713.html">ISO\\u00a0713, Tableau 1–1</a>
           <a href="spec/assets/iso713.html">ISO\\u00a0713, Article 1, Tableau 1</a>
           <a href="spec/assets/iso713.html">ISO\\u00a0713, Article 1</a>
           <a href="spec/assets/iso713.html">ISO\\u00a0713, Article 1.5</a>
           <a href="spec/assets/iso713.html">A</a>
           <a href="spec/assets/iso713.html">ISO\\u00a0713, Ensemble du texte</a>
           <a href="spec/assets/iso713.html">ISO\\u00a0713, Prelude 7</a>
           <a href="spec/assets/iso713.html">A</a>
           <a href="spec/assets/iso713.html#xyz">ISO\\u00a0713</a>
           <a href="spec/assets/iso713.html#xyz">ISO\\u00a0713, Article 1</a>
           <a href="spec/assets/iso714.svg">ISO\\u00a0714</a>
         </p>
       </div>
    OUTPUT
    output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    xml = IsoDoc::HtmlConvert.new({})
      .convert("test", output, true)
    expect(Canon.format_xml(Nokogiri::XML(strip_guid(xml))
      .at("//div[h1/@class='ForewordTitle']").to_xml))
      .to be_equivalent_to Canon.format_xml(html)
    xml = IsoDoc::WordConvert.new({})
      .convert("test", output, true)
    expect(Canon.format_xml(Nokogiri::XML(strip_guid(xml))
      .at("//div[h1/@class='ForewordTitle']").to_xml))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "processes eref content pointing to reference with attachment URL" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>fr</language>
          </bibdata>
          <preface><foreword>
          <p>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="attachment">https://example.google.com</uri>
        <uri type="citation">https://www.google.com</uri>
        <uri type="citation" language="en">https://www.google.com/en</uri>
        <uri type="citation" language="fr">https://www.google.com/fr</uri>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <foreword id="_" displayorder="2">
          <title id="_">Avant-propos</title>
          <fmt-title id="_" depth="1">
             <semx element="title" source="_">Avant-propos</semx>
          </fmt-title>
          <p>
             <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
             <semx element="eref" source="_">
                <fmt-link attachment="true" target="https://example.google.com">ISO\\u00a0712</fmt-link>
             </semx>
          </p>
       </foreword>
    OUTPUT
    output = IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(output)
      .at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes eref content pointing to hidden bibliographic entries" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p id="A">
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
          <eref type="inline" bibitemid="ISO712"/>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO713"><localityStack connective="and"><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom></locality>A</eref>
          <eref type="inline" bibitemid="ISO713"><locality type="whole"></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713" citeas="ISO 713">A</eref>
          <eref type="inline" bibitemid="ISO713"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO713"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true" hidden="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard" hidden="true">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type="citation">http://www.example.com</uri>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO713" type="standard" hidden="true">
        <title format="text/plain">Cereals and cereal products</title>
        <uri type='src'>https://www.iso.org/standard/3944.html</uri>
        <uri type='rss'>https://www.iso.org/contents/data/standard/00/39/3944.detail.rss</uri>
        <docidentifier>ISO 713</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
    INPUT
    presxml = <<~PRESXML
      <p id="A">
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" id="_"/>
          <semx element="eref" source="_">
             <fmt-link target="http://www.example.com">ISO\\u00a0712</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO712" id="_"/>
          <semx element="eref" source="_">
             <fmt-link target="http://www.example.com">ISO\\u00a0712</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="table">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <localityStack connective="and">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </localityStack>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <localityStack connective="and">
                <locality type="table">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </localityStack>
             <localityStack connective="and">
                <locality type="clause">
                   <referenceFrom>1</referenceFrom>
                </locality>
             </localityStack>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">
                ISO\\u00a0713, Table 1
                <span class="fmt-conn">and</span>
                Clause 1
             </fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="table">
                <referenceFrom>1</referenceFrom>
                <referenceTo>1</referenceTo>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1–1</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
             <locality type="table">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Clause 1, Table 1</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Clause 1</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="clause">
                <referenceFrom>1.5</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Clause 1.5</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="table">
                <referenceFrom>1</referenceFrom>
             </locality>
             A
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">A</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="whole"/>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Whole of text</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="locality:prelude">
                <referenceFrom>7</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Prelude 7</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" citeas="ISO 713" id="_">A</eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html">A</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="anchor">
                <referenceFrom>xyz</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html#xyz">ISO\\u00a0713</fmt-link>
          </semx>
          <eref type="inline" bibitemid="ISO713" id="_">
             <locality type="anchor">
                <referenceFrom>xyz</referenceFrom>
             </locality>
             <locality type="clause">
                <referenceFrom>1</referenceFrom>
             </locality>
          </eref>
          <semx element="eref" source="_">
             <fmt-link target="https://www.iso.org/standard/3944.html#xyz">ISO\\u00a0713, Clause 1</fmt-link>
          </semx>
       </p>
    PRESXML
    html = <<~OUTPUT
      <p id="A">
         <a href="http://www.example.com">ISO\\u00a0712</a>
         <a href="http://www.example.com">ISO\\u00a0712</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1 and Clause 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1–1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Clause 1, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Clause 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Clause 1.5</a>
         <a href="https://www.iso.org/standard/3944.html">A</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Whole of text</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Prelude 7</a>
         <a href="https://www.iso.org/standard/3944.html">A</a>
         <a href="https://www.iso.org/standard/3944.html#xyz">ISO\\u00a0713</a>
         <a href="https://www.iso.org/standard/3944.html#xyz">ISO\\u00a0713, Clause 1</a>
      </p>
    OUTPUT
    word = <<~OUTPUT
      <p id="A">
         <a href="http://www.example.com">ISO\\u00a0712</a>
         <a href="http://www.example.com">ISO\\u00a0712</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1 and Clause 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Table 1–1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Clause 1, Table 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Clause 1</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Clause 1.5</a>
         <a href="https://www.iso.org/standard/3944.html">A</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Whole of text</a>
         <a href="https://www.iso.org/standard/3944.html">ISO\\u00a0713, Prelude 7</a>
         <a href="https://www.iso.org/standard/3944.html">A</a>
         <a href="https://www.iso.org/standard/3944.html#xyz">ISO\\u00a0713</a>
         <a href="https://www.iso.org/standard/3944.html#xyz">ISO\\u00a0713, Clause 1</a>
      </p>
    OUTPUT
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options
      .merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(html)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(
      IsoDoc::WordConvert.new({})
      .convert("test", pres_output, true),
    )
  .at("//p[@id = 'A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(word)
  end

  it "processes eref content with Unicode characters" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <eref type="inline" bibitemid="ISO712" citeas="BSI BS EN ISO 19011:2018&#8201;&#8212;&#8201;TC"/></p>
      </foreword></preface>
              <bibliography>
          <references id='_normative_references' obligation='informative' normative='true'>
          <title>Normative References</title>
            <bibitem id='ISO712' type='standard'>
              <title format='text/plain'>Cereals and cereal products</title>
              <docidentifier>BSI BS EN ISO 19011:2018&#8201;&#8212;&#8201;TC</docidentifier>
              <contributor>
                <role type='publisher'/>
                <organization>
                  <abbreviation>ISO</abbreviation>
                </organization>
              </contributor>
            </bibitem>
           </references></bibliography>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
        <foreword id="_" displayorder="2">
           <title id="_">Foreword</title>
           <fmt-title id="_" depth="1">
              <semx element="title" source="_">Foreword</semx>
           </fmt-title>
           <p>
              <eref type="inline" bibitemid="ISO712" citeas="BSI BS EN ISO 19011:2018\\u2009—\\u2009TC" id="_"/>
              <semx element="eref" source="_">
                 <fmt-xref type="inline" target="ISO712">BSI\\u00a0BS\\u00a0EN\\u00a0ISO\\u00a019011:2018\\u2009—\\u2009TC</fmt-xref>
              </semx>
           </p>
        </foreword>
      </foreword>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))
    expect(strip_guid(Canon.format_xml(xml.at("//xmlns:foreword").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes erefstack" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
       <clause id="A1" inline-header="false" obligation="normative">
       <title>Section</title>
       <p id="A2">
       <erefstack><eref connective="from" bibitemid="A" citeas="A" type="inline" /><eref connective="to" bibitemid="B" citeas="B" type="inline" /></erefstack>
       </p>
       </clause>
       </sections>
       <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <docidentifier type="metanorma">[110]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO16634" type="standard">
        <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
        <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
        <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
        <date type="published"><on>--</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <note format="text/plain" type="Unpublished-Status" reference="1">Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
        <extent type="part">
        <referenceFrom>all</referenceFrom>
        </extent>
      </bibitem>
      </bibliography>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <p id="A2">
         <erefstack id="_">
            <eref connective="from" bibitemid="A" citeas="A" type="inline" id="_"/>
            <eref connective="to" bibitemid="B" citeas="B" type="inline" id="_"/>
         </erefstack>
         <semx element="erefstack" source="_">
            <semx element="eref" source="_">
               <fmt-eref connective="from" bibitemid="A" citeas="A" type="inline">A</fmt-eref>
            </semx>
            <span class="fmt-conn">to</span>
            <semx element="eref" source="_">
               <fmt-eref connective="to" bibitemid="B" citeas="B" type="inline">B</fmt-eref>
            </semx>
         </semx>
      </p>
    OUTPUT
    html = <<~OUTPUT
      <p id="A2">
       A to B
       </p>
    OUTPUT
    xml = Nokogiri::XML(IsoDoc::PresentationXMLConvert.new(presxml_options)
        .convert("test", input, true))
    xml = xml.at("//xmlns:p[@id = 'A2']")
    expect(strip_guid(Canon.format_xml(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    pres_output = IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(pres_output)
      .at("//xmlns:p[@id = 'A2']").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(
      IsoDoc::HtmlConvert.new({})
      .convert("test", pres_output, true),
    )
      .at("//p[@id = 'A2']").to_xml)))
      .to be_equivalent_to Canon.format_xml(html)
  end

  it "processes formatting in eref/@citeas" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
               <preface>
           <foreword id='_' obligation='informative'>
             <title>Foreword</title>
             <p id='A'>
               <eref type='inline' bibitemid='iso124' citeas='[&amp;#x3c;strong&amp;#x3e;A&amp;#x3c;/strong&amp;#x3e;.&amp;#x3c;fn reference=&amp;#x22;1&amp;#x22;&amp;#x3e;&amp;#xa;  &amp;#x3c;p&amp;#x3e;hello&amp;#x3c;/p&amp;#x3e;&amp;#xa;&amp;#x3c;/fn&amp;#x3e;]'/>
             </p>
           </foreword>
         </preface>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
      <p id="A">
         <eref type="inline" bibitemid="iso124" citeas="[&amp;#x3c;strong&amp;#x3e;A&amp;#x3c;/strong&amp;#x3e;.&amp;#x3c;fn reference=&amp;#x22;1&amp;#x22;&amp;#x3e;&amp;#xa;  &amp;#x3c;p&amp;#x3e;hello&amp;#x3c;/p&amp;#x3e;&amp;#xa;&amp;#x3c;/fn&amp;#x3e;]" id="_"/>
         <semx element="eref" source="_">
            <fmt-eref type="inline" bibitemid="iso124" citeas="[&amp;#x3c;strong&amp;#x3e;A&amp;#x3c;/strong&amp;#x3e;.&amp;#x3c;fn reference=&amp;#x22;1&amp;#x22;&amp;#x3e;&amp;#xa;  &amp;#x3c;p&amp;#x3e;hello&amp;#x3c;/p&amp;#x3e;&amp;#xa;&amp;#x3c;/fn&amp;#x3e;]">
               [
               <strong>A</strong>
               .
               <fn reference="1">
                  <p>hello</p>
               </fn>
               ]
            </fmt-eref>
         </semx>
      </p>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:p[@id = 'A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "combines locality stacks with connectives" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
                  <p id='_'>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                  <locality type="table">
                    <referenceFrom>2</referenceFrom>
                  </locality>
                  </locality>
                </localityStack>
                text
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>7</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='annex'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='or'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
                text
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>8</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>10</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
            </p>
          </clause>
        </sections>
        <bibliography>
          <references id='_' normative='false' obligation='informative'>
            <title>Bibliography</title>
            <bibitem id='ref1'>
              <formattedref format='application/x-isodoc+xml'>
                <em>Standard</em>
              </formattedref>
              <docidentifier>XYZ</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu" type="presentation">
         <p id="_">
            <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
               <localityStack connective="from">
                  <locality type="clause">
                     <referenceFrom>3</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="to">
                  <locality type="clause">
                     <referenceFrom>5</referenceFrom>
                  </locality>
               </localityStack>
            </eref>
            <semx element="eref" source="_">
               <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
                  <localityStack connective="from">
                     <locality type="clause">
                        <referenceFrom>3</referenceFrom>
                     </locality>
                  </localityStack>
                  <localityStack connective="to">
                     <locality type="clause">
                        <referenceFrom>5</referenceFrom>
                     </locality>
                  </localityStack>
                  XYZ, Clauses 3
                  <span class="fmt-conn">to</span>
                  5
               </fmt-eref>
            </semx>
            <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
               <localityStack connective="from">
                  <locality type="clause">
                     <referenceFrom>3</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="to">
                  <locality type="clause">
                     <referenceFrom>5</referenceFrom>
                  </locality>
                  <locality type="table">
                     <referenceFrom>2</referenceFrom>
                  </locality>
               </localityStack>
            </eref>
            <semx element="eref" source="_">
               <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
                  <localityStack connective="from">
                     <locality type="clause">
                        <referenceFrom>3</referenceFrom>
                     </locality>
                  </localityStack>
                  <localityStack connective="to">
                     <locality type="clause">
                        <referenceFrom>5</referenceFrom>
                     </locality>
                     <locality type="table">
                        <referenceFrom>2</referenceFrom>
                     </locality>
                  </localityStack>
                  XYZ, Clause 3
                  <span class="fmt-conn">to</span>
                  Clause 5, Table 2
               </fmt-eref>
            </semx>
            text
         </p>
         <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
            <localityStack connective="and">
               <locality type="clause">
                  <referenceFrom>3</referenceFrom>
               </locality>
            </localityStack>
            <localityStack connective="and">
               <locality type="clause">
                  <referenceFrom>5</referenceFrom>
               </locality>
            </localityStack>
         </eref>
         <semx element="eref" source="_">
            <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
               <localityStack connective="and">
                  <locality type="clause">
                     <referenceFrom>3</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="and">
                  <locality type="clause">
                     <referenceFrom>5</referenceFrom>
                  </locality>
               </localityStack>
               XYZ, Clauses 3
               <span class="fmt-conn">and</span>
               5
            </fmt-eref>
         </semx>
         <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
            <localityStack connective="and">
               <locality type="clause">
                  <referenceFrom>3</referenceFrom>
               </locality>
            </localityStack>
            <localityStack connective="and">
               <locality type="clause">
                  <referenceFrom>5</referenceFrom>
               </locality>
            </localityStack>
            <localityStack connective="and">
               <locality type="clause">
                  <referenceFrom>7</referenceFrom>
               </locality>
            </localityStack>
         </eref>
         <semx element="eref" source="_">
            <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
               <localityStack connective="and">
                  <locality type="clause">
                     <referenceFrom>3</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="and">
                  <locality type="clause">
                     <referenceFrom>5</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="and">
                  <locality type="clause">
                     <referenceFrom>7</referenceFrom>
                  </locality>
               </localityStack>
               XYZ, Clauses 3
               <span class="fmt-enum-comma">,</span>
               5
               <span class="fmt-enum-comma">,</span>
               <span class="fmt-conn">and</span>
               7
            </fmt-eref>
         </semx>
         <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
            <localityStack connective="and">
               <locality type="clause">
                  <referenceFrom>3</referenceFrom>
               </locality>
            </localityStack>
            <localityStack connective="and">
               <locality type="annex">
                  <referenceFrom>5</referenceFrom>
               </locality>
            </localityStack>
         </eref>
         <semx element="eref" source="_">
            <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
               <localityStack connective="and">
                  <locality type="clause">
                     <referenceFrom>3</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="and">
                  <locality type="annex">
                     <referenceFrom>5</referenceFrom>
                  </locality>
               </localityStack>
               XYZ, Clause 3
               <span class="fmt-conn">and</span>
               Annex 5
            </fmt-eref>
         </semx>
         <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
            <localityStack connective="and">
               <locality type="clause">
                  <referenceFrom>3</referenceFrom>
               </locality>
            </localityStack>
            <localityStack connective="or">
               <locality type="clause">
                  <referenceFrom>5</referenceFrom>
               </locality>
            </localityStack>
            text
         </eref>
         <semx element="eref" source="_">
            <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
               <localityStack connective="and">
                  <locality type="clause">
                     <referenceFrom>3</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="or">
                  <locality type="clause">
                     <referenceFrom>5</referenceFrom>
                  </locality>
               </localityStack>
               text
            </fmt-eref>
         </semx>
         <eref type="inline" bibitemid="ref1" citeas="XYZ" id="_">
            <localityStack connective="from">
               <locality type="clause">
                  <referenceFrom>3</referenceFrom>
               </locality>
            </localityStack>
            <localityStack connective="to">
               <locality type="clause">
                  <referenceFrom>5</referenceFrom>
               </locality>
            </localityStack>
            <localityStack connective="and">
               <locality type="clause">
                  <referenceFrom>8</referenceFrom>
               </locality>
            </localityStack>
            <localityStack connective="to">
               <locality type="clause">
                  <referenceFrom>10</referenceFrom>
               </locality>
            </localityStack>
         </eref>
         <semx element="eref" source="_">
            <fmt-eref type="inline" bibitemid="ref1" citeas="XYZ">
               <localityStack connective="from">
                  <locality type="clause">
                     <referenceFrom>3</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="to">
                  <locality type="clause">
                     <referenceFrom>5</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="and">
                  <locality type="clause">
                     <referenceFrom>8</referenceFrom>
                  </locality>
               </localityStack>
               <localityStack connective="to">
                  <locality type="clause">
                     <referenceFrom>10</referenceFrom>
                  </locality>
               </localityStack>
               XYZ, Clauses 3
               <span class="fmt-conn">to</span>
               5
               <span class="fmt-conn">and</span>
               8
               <span class="fmt-conn">to</span>
               10
            </fmt-eref>
         </semx>
      </itu-standard>
    OUTPUT
    expect(strip_guid(Canon.format_xml(IsoDoc::PresentationXMLConvert
    .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
