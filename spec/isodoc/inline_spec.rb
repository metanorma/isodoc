require "spec_helper"

RSpec.describe IsoDoc do
  it "cases xrefs" do
  expect(xmlpp(IsoDoc::PresentationXMLConvert.new({i18nyaml: "spec/assets/i18n.yaml"}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <clause id="A">
    <table id="B">
    </table>
    </clause>
    <clause id="C">
    <p>This is <xref target="A"/> and <xref target="B"/>.
    This is <xref target="A" case="capital"/> and <xref target="B" case="lowercase"/>.
    <xref target="A"/> is clause <em>initial.</em><br/>
    <xref target="A"/> is too.  </p>
    <p><xref target="A"/> is also.</p>
</clause>
</sections>
</iso-standard>
INPUT
<?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <sections>
    <clause id='A'>
    <title>1.</title>
      <table id='B'>
        <name>Tabelo 1</name>
      </table>
    </clause>
    <clause id='C'>
    <title>2.</title>
      <p>
        This is
        <xref target='A'>kla&#x16D;zo 1</xref>
         and
        <xref target='B'>Tabelo 1</xref>
        . This is
        <xref target='A' case='capital'>Kla&#x16D;zo 1</xref>
         and
        <xref target='B' case='lowercase'>tabelo 1</xref>
        .
        <xref target='A'>Kla&#x16D;zo 1</xref>
         is clause
        <em>initial.</em>
        <br/>
        <xref target='A'>Kla&#x16D;zo 1</xref>
         is too.
      </p>
      <p>
        <xref target='A'>Kla&#x16D;zo 1</xref>
         is also.
      </p>
    </clause>
  </sections>
</iso-standard>
OUTPUT
end

  it "processes inline formatting" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <em>A</em> <strong>B</strong> <sup>C</sup> <sub>D</sub> <tt>E</tt>
    <strike>F</strike> <smallcap>G</smallcap> <keyword>I</keyword> <br/> <hr/>
    <bookmark id="H"/> <pagebreak/> <pagebreak orientation="landscape"/>
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
       <i>A</i> <b>B</b> <sup>C</sup> <sub>D</sub> <tt>E</tt>
       <s>F</s> <span style="font-variant:small-caps;">G</span> <span class="keyword">I</span> <br/> <hr/>
       <a id="H"/> <br/> <br/>
       </p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

    it "processes inline formatting (Word)" do
    expect(xmlpp(IsoDoc::WordConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface/><sections><clause>
    <p>
    <em>A</em> <strong>B</strong> <sup>C</sup> <sub>D</sub> <tt>E</tt>
    <strike>F</strike> <smallcap>G</smallcap> <keyword>I</keyword> <br/> <hr/>
    <bookmark id="H"/> <pagebreak/> <pagebreak orientation="landscape"/>
    </p>
    </clause></sections>
    </iso-standard>
    INPUT
    #{WORD_HDR}
      <p class='zzSTDTitle1'/>
      <div>
        <h1/>
        <p>
          <i>A</i>
          <b>B</b>
          <sup>C</sup>
          <sub>D</sub>
          <tt>E</tt>
          <s>F</s>
          <span style='font-variant:small-caps;'>G</span>
          <span class='keyword'>I</span>
          <br/>
          <hr/>
          <a id='H'/>
          <p>
            <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
          </p>
          <p>
            <br clear='all' class='section' orientation='landscape'/>
          </p>
        </p>
      </div>
    </div>
  </body>
</html>

    OUTPUT
  end

    it "ignores index entries" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p><index primary="A" secondary="B" tertiary="C"/></p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
        #{HTML_HDR}
             <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <p/>
             </div>
             <p class='zzSTDTitle1'/>
           </div>
         </body>
       </html>
    OUTPUT
    end

     it "processes concept markup" do
       input = <<~INPUT
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <ul>
    <li><concept term='term'>
        <xref target='clause1'/>
      </concept></li>
    <li><concept term='term'>
        <xref target='clause1'>w[o]rd</xref>
      </concept></li>
      <li><concept term='term'>
        <eref bibitemid="ISO712" type="inline" citeas="ISO 712"/>
      </concept></li>
      <li><concept term='term'>
        <eref bibitemid="ISO712" type="inline" citeas="ISO 712">word</eref>
      </concept></li>
      <li><concept>
        <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
          <locality type='clause'>
            <referenceFrom>3.1</referenceFrom>
          </locality>
          <locality type='figure'>
            <referenceFrom>a</referenceFrom>
          </locality>
        </eref>
      </concept></li>
      <li><concept>
        <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
        <localityStack>
          <locality type='clause'>
            <referenceFrom>3.1</referenceFrom>
          </locality>
        </localityStack>
        <localityStack>
          <locality type='figure'>
            <referenceFrom>b</referenceFrom>
          </locality>
        </localityStack>
        </eref>
      </concept></li>
      <li><concept>
        <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
        <localityStack>
          <locality type='clause'>
            <referenceFrom>3.1</referenceFrom>
          </locality>
        </localityStack>
        <localityStack>
          <locality type='figure'>
            <referenceFrom>b</referenceFrom>
          </locality>
        </localityStack>
        <em>word</em>
        </eref>
      </concept></li>
      <li><concept term='term'>
        <termref base='IEV' target='135-13-13'/>
      </concept></li>
      <li><concept term='term'>
        <termref base='IEV' target='135-13-13'><em>word</em> word</termref>
      </concept></li>
      </ul>
    </p>
    </foreword></preface>
    <sections>
    <clause id="clause1"><title>Clause 1</title></clause>
    </sections>
    <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
    <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals or cereal products</title>
  <title type="main" format="text/plain">Cereals and cereal products</title>
  <docidentifier type="ISO">ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
</bibitem>
</references></bibliography>
    </iso-standard>
    INPUT
    presxml = <<~OUTPUT
       <iso-standard xmlns="http://riboseinc.com/isoxml">
           <preface><foreword>
           <p>
           <ul>
           <li><concept term="term">
               <xref target="clause1">Clause 2</xref>
             </concept></li>
           <li><concept term="term">
               <xref target="clause1">w[o]rd</xref>
             </concept></li>
             <li><concept term="term">
               <eref bibitemid="ISO712" type="inline" citeas="ISO 712">ISO 712</eref>
             </concept></li>
             <li><concept term="term">
               <eref bibitemid="ISO712" type="inline" citeas="ISO 712">word</eref>
             </concept></li>
             <li><concept>
               <eref bibitemid="ISO712" type="inline" citeas="ISO 712"><locality type="clause">
                   <referenceFrom>3.1</referenceFrom>
                 </locality><locality type="figure">
                   <referenceFrom>a</referenceFrom>
                 </locality>ISO 712, Clause 3.1, Figure a</eref>
             </concept></li>
             <li><concept>
               <eref bibitemid="ISO712" type="inline" citeas="ISO 712"><localityStack>
                 <locality type="clause">
                   <referenceFrom>3.1</referenceFrom>
                 </locality>
               </localityStack><localityStack>
                 <locality type="figure">
                   <referenceFrom>b</referenceFrom>
                 </locality>
               </localityStack>ISO 712, Clause 3.1; Figure b</eref>
             </concept></li>
             <li><concept>
               <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
               <localityStack>
                 <locality type="clause">
                   <referenceFrom>3.1</referenceFrom>
                 </locality>
               </localityStack>
               <localityStack>
                 <locality type="figure">
                   <referenceFrom>b</referenceFrom>
                 </locality>
               </localityStack>
               <em>word</em>
               </eref>
             </concept></li>
             <li><concept term="term">
               <termref base="IEV" target="135-13-13"/>
             </concept></li>
             <li><concept term="term">
               <termref base="IEV" target="135-13-13"><em>word</em> word</termref>
             </concept></li>
             </ul>
           </p>
           </foreword></preface>
           <sections>
           <clause id="clause1"><title depth='1'>2.<tab/>Clause 1</title>
        </clause>
           </sections>
           <bibliography><references id="_normative_references" obligation="informative" normative="true">
            <title depth='1'>1.<tab/>Normative References</title>
           <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
       <bibitem id="ISO712" type="standard">
         <title format="text/plain">Cereals or cereal products</title>
         <title type="main" format="text/plain">Cereals and cereal products</title>
         <docidentifier type="ISO">ISO 712</docidentifier>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Organization for Standardization</name>
           </organization>
         </contributor>
       </bibitem>
       </references></bibliography>
           </iso-standard>
OUTPUT

    html = <<~OUTPUT
        #{HTML_HDR}
        <br/>
       <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p>
              <ul>
              <li>Clause 2</li>
              <li>w[o]rd</li>
                <li>ISO 712</li>
                <li>word</li>
                <li>ISO 712, Clause 3.1, Figure a</li>
                <li>ISO 712, Clause 3.1; Figure b</li>
                <li><i>word</i></li>
                <li>[Term defined in Termbase IEV, term ID 135-13-13]</li>
                <li><i>word</i> word</li>
                </ul>
              </p>
             </div>
             <p class="zzSTDTitle1"/>
             <div><h1>1.&#160; Normative References</h1>
              <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
          <p id="ISO712" class="NormRef">ISO 712, <i>Cereals and cereal products</i></p>
          </div>
             <div id="clause1">
               <h1>2.&#160; Clause 1</h1>
             </div>
           </div>
         </body>
       </html>
OUTPUT
      expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
      expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    end

  it "processes embedded inline formatting" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <em><strong>&lt;</strong></em> <tt><link target="B"/></tt> <xref target="_http_1_1">Requirement <tt>/req/core/http</tt></xref> <eref type="inline" bibitemid="ISO712" citeas="ISO 712">Requirement <tt>/req/core/http</tt></eref> 
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
       <i><b>&lt;</b></i> <tt><a href="B">B</a></tt> <a href="#_http_1_1">Requirement <tt>/req/core/http</tt></a>  <a href="#ISO712">Requirement <tt>/req/core/http</tt></a> 
       </p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes inline images" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
  <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
  </p>
  </foreword></preface>
  </iso-standard>
  INPUT
    #{HTML_HDR}
      <br/>
      <div>
        <h1 class='ForewordTitle'>Foreword</h1>
        <p>
          <img src='rice_images/rice_image1.png' height='20' width='30' title='titletxt' alt='alttext'/>
        </p>
      </div>
      <p class='zzSTDTitle1'/>
    </div>
  </body>
</html>
  OUTPUT
  end

  it "processes links" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <link target="http://example.com"/>
    <link target="http://example.com">example</link>
    <link target="http://example.com" alt="tip">example</link>
    <link target="mailto:fred@example.com"/>
    <link target="mailto:fred@example.com">mailto:fred@example.com</link>
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
       <a href="http://example.com">http://example.com</a>
       <a href="http://example.com">example</a>
       <a href="http://example.com" title="tip">example</a>
       <a href="mailto:fred@example.com">fred@example.com</a>
       <a href="mailto:fred@example.com">mailto:fred@example.com</a>
       </p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes unrecognised markup" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <barry fred="http://example.com">example</barry>
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
       <para><b role="strong">&lt;barry fred="http://example.com"&gt;example&lt;/barry&gt;</b></para>
       </p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes AsciiMath and MathML" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true).sub(/<html/, "<html xmlns:m='m'"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <stem type="AsciiMath">&lt;A&gt;</stem>
    <stem type="MathML"><m:math><m:row>X</m:row></m:math></stem>
    <stem type="None">Latex?</stem>
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{HTML_HDR.sub(/<html/, "<html xmlns:m='m'")}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
       <span class="stem">(#(&lt;A&gt;)#)</span>
       <span class="stem"><m:math>
         <m:row>X</m:row>
       </m:math></span>
       <span class="stem">Latex?</span>
       </p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "overrides AsciiMath delimiters" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <stem type="AsciiMath">A</stem>
    (#((Hello))#)
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
       <span class="stem">(#(((A)#)))</span>
       (#((Hello))#)
       </p>
               </div>
               <p class="zzSTDTitle1"/>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes eref types" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <eref type="footnote" bibitemid="ISO712" citeas="ISO 712">A</stem>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</stem>
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
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <sup><a href="#ISO712">A</a></sup>
           <a href="#ISO712">A</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div>
                 <h1>Normative References</h1>
                 <p id="ISO712" class="NormRef">ISO 712, <i>Cereals and cereal products</i></p>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes eref content" do
    input = <<~INPUT
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
    <eref type="inline" bibitemid="ISO712"/>
    <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><localityStack><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
    <eref type="inline" bibitemid="ISO712"><localityStack><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality>A</eref>
    <eref type="inline" bibitemid="ISO712"><locality type="whole"></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
    <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
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
       <iso-standard xmlns="http://riboseinc.com/isoxml">
           <preface><foreword>
           <p>
           <eref type="inline" bibitemid="ISO712" citeas="ISO 712">ISO 712</eref>
           <eref type="inline" bibitemid="ISO712">ISO 712</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality>ISO 712, Table 1</eref>
           <eref type="inline" bibitemid="ISO712"><localityStack><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack>ISO 712, Table 1</eref>
           <eref type="inline" bibitemid="ISO712"><localityStack><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack>ISO 712, Table 1; Clause 1</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality>ISO 712, Table 1&#x2013;1</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality>ISO 712, Clause 1, Table 1</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality>ISO 712, Clause 1</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality>ISO 712, Clause 1.5</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality>A</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="whole"/>ISO 712, Whole of text</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality>ISO 712, Prelude 7</eref>
           <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality>ISO 712</eref>
           <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>1</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality>ISO 712, Clause 1</eref>
           </p>
           </foreword></preface>
           <bibliography><references id="_normative_references" obligation="informative" normative="true"><title depth='1'>1.<tab/>Normative References</title>
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
OUTPUT

html = <<~OUTPUT
    #{HTML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>
           <a href="#ISO712">ISO 712</a>
           <a href="#ISO712">ISO 712</a>
           <a href="#ISO712">ISO 712, Table 1</a>
           <a href='#ISO712'>ISO 712, Table 1</a>
<a href='#ISO712'>ISO 712, Table 1; Clause 1</a>
           <a href="#ISO712">ISO 712, Table 1&#8211;1</a>
           <a href="#ISO712">ISO 712, Clause 1, Table 1</a>
           <a href="#ISO712">ISO 712, Clause 1</a>
           <a href="#ISO712">ISO 712, Clause 1.5</a>
           <a href="#ISO712">A</a>
           <a href="#ISO712">ISO 712, Whole of text</a>
           <a href="#ISO712">ISO 712, Prelude 7</a>
           <a href="#ISO712">A</a>
           <a href='#ISO712'>ISO 712</a>
           <a href='#ISO712'>ISO 712, Clause 1</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div>
                 <h1>1.&#160; Normative References</h1>
                 <p id="ISO712" class="NormRef">ISO 712, <i> Cereals and cereal products</i></p>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
  end

      it "processes eref content pointing to reference with citation URL" do
        input = <<~INPUT
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
    <eref type="inline" bibitemid="ISO712"/>
    <eref type="inline" bibitemid="ISO713"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO713"><localityStack><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
    <eref type="inline" bibitemid="ISO713"><localityStack><locality type="table"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack></eref>
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
    <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
<bibitem id="ISO712" type="standard">
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
<bibitem id="ISO713" type="standard">
  <title format="text/plain">Cereals and cereal products</title>
  <uri type="citation">spec/assets/iso713</uri>
  <docidentifier>ISO 713</docidentifier>
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
       <iso-standard xmlns='http://riboseinc.com/isoxml'>
         <preface>
           <foreword>
             <p>
               <eref type='inline' bibitemid='ISO712' citeas='ISO 712'>ISO 712</eref>
               <eref type='inline' bibitemid='ISO712'>ISO 712</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='table'>
                   <referenceFrom>1</referenceFrom>
                 </locality>ISO 713, Table 1</eref>
               <eref type='inline' bibitemid='ISO713'><localityStack><locality type='table'><referenceFrom>1</referenceFrom></locality></localityStack>ISO 713, Table 1</eref>
               <eref type='inline' bibitemid='ISO713'><localityStack><locality type='table'><referenceFrom>1</referenceFrom></locality></localityStack><localityStack><locality type='clause'><referenceFrom>1</referenceFrom></locality></localityStack>ISO 713, Table 1; Clause 1</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='table'>
                   <referenceFrom>1</referenceFrom>
                   <referenceTo>1</referenceTo>
                 </locality>ISO 713, Table 1&#x2013;1</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='clause'><referenceFrom>1</referenceFrom></locality><locality type='table'><referenceFrom>1</referenceFrom></locality>ISO 713, Clause 1, Table 1</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='clause'>
                   <referenceFrom>1</referenceFrom>
                 </locality>ISO 713, Clause 1</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='clause'>
                   <referenceFrom>1.5</referenceFrom>
                 </locality>ISO 713, Clause 1.5</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='table'>
                   <referenceFrom>1</referenceFrom>
                 </locality>A</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='whole'/>ISO 713, Whole of text</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='locality:prelude'>
                   <referenceFrom>7</referenceFrom>
                 </locality>ISO 713, Prelude 7</eref>
               <eref type='inline' bibitemid='ISO713' citeas='ISO 713'>A</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='anchor'><referenceFrom>xyz</referenceFrom></locality>ISO 713</eref>
               <eref type='inline' bibitemid='ISO713'><locality type='anchor'><referenceFrom>xyz</referenceFrom></locality><locality type='clause'><referenceFrom>1</referenceFrom></locality>ISO 713, Clause 1</eref>
             </p>
           </foreword>
         </preface>
         <bibliography>
           <references id='_normative_references' obligation='informative' normative='true'>
           <title depth='1'>1.<tab/>Normative References</title>
             <bibitem id='ISO712' type='standard'>
               <title format='text/plain'>Cereals and cereal products</title>
               <uri type='citation'>http://www.example.com</uri>
               <docidentifier>ISO 712</docidentifier>
               <contributor>
                 <role type='publisher'/>
                 <organization>
                   <abbreviation>ISO</abbreviation>
                 </organization>
               </contributor>
             </bibitem>
             <bibitem id='ISO713' type='standard'>
               <title format='text/plain'>Cereals and cereal products</title>
               <uri type='citation'>spec/assets/iso713</uri>
               <docidentifier>ISO 713</docidentifier>
               <contributor>
                 <role type='publisher'/>
                 <organization>
                   <abbreviation>ISO</abbreviation>
                 </organization>
               </contributor>
             </bibitem>
           </references>
         </bibliography>
       </iso-standard>
OUTPUT

    html = <<~OUTPUT
        #{HTML_HDR}
      <br/>
      <div>
        <h1 class='ForewordTitle'>Foreword</h1>
        <p>
          <a href='http://www.example.com'>ISO 712</a>
          <a href='http://www.example.com'>ISO 712</a>
          <a href='spec/assets/iso713.html'>ISO 713, Table 1</a>
          <a href='spec/assets/iso713.html'>ISO 713, Table 1</a>
          <a href='spec/assets/iso713.html'>ISO 713, Table 1; Clause 1</a>
          <a href='spec/assets/iso713.html'>ISO 713, Table 1&#8211;1</a>
          <a href='spec/assets/iso713.html'>ISO 713, Clause 1, Table 1</a>
          <a href='spec/assets/iso713.html'>ISO 713, Clause 1</a>
          <a href='spec/assets/iso713.html'>ISO 713, Clause 1.5</a>
          <a href='spec/assets/iso713.html'>A</a>
          <a href='spec/assets/iso713.html'>ISO 713, Whole of text</a>
          <a href='spec/assets/iso713.html'>ISO 713, Prelude 7</a>
          <a href='spec/assets/iso713.html'>A</a>
          <a href='spec/assets/iso713.html#xyz'>ISO 713</a>
          <a href='spec/assets/iso713.html#xyz'>ISO 713, Clause 1</a>
        </p>
      </div>
      <p class='zzSTDTitle1'/>
      <div>
        <h1>1.&#160; Normative References</h1>
        <p id='ISO712' class='NormRef'>
          ISO 712,
          <i>Cereals and cereal products</i>
        </p>
        <p id='ISO713' class='NormRef'>
  ISO 713,
  <i>Cereals and cereal products</i>
</p>
      </div>
    </div>
  </body>
</html>
OUTPUT

word = <<~OUTPUT
    <html  xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
    <head>
    <style>
    </style>
  </head>
  <body lang='EN-US' link='blue' vlink='#954F72'>
    <div class='WordSection1'>
      <p>&#160;</p>
    </div>
    <p>
      <br clear='all' class='section'/>
    </p>
    <div class='WordSection2'>
      <p>
        <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
      </p>
      <div>
        <h1 class='ForewordTitle'>Foreword</h1>
        <p>
          <a href='http://www.example.com'>ISO 712</a>
          <a href='http://www.example.com'>ISO 712</a>
          <a href='spec/assets/iso713.doc'>ISO 713, Table 1</a>
          <a href='spec/assets/iso713.doc'>ISO 713, Table 1</a>
          <a href='spec/assets/iso713.doc'>ISO 713, Table 1; Clause 1</a>
          <a href='spec/assets/iso713.doc'>ISO 713, Table 1&#8211;1</a>
          <a href='spec/assets/iso713.doc'>ISO 713, Clause 1, Table 1</a>
          <a href='spec/assets/iso713.doc'>ISO 713, Clause 1</a>
          <a href='spec/assets/iso713.doc'>ISO 713, Clause 1.5</a>
          <a href='spec/assets/iso713.doc'>A</a>
          <a href='spec/assets/iso713.doc'>ISO 713, Whole of text</a>
          <a href='spec/assets/iso713.doc'>ISO 713, Prelude 7</a>
          <a href='spec/assets/iso713.doc'>A</a>
          <a href='spec/assets/iso713.doc#xyz'>ISO 713</a>
          <a href='spec/assets/iso713.doc#xyz'>ISO 713, Clause 1</a>
        </p>
      </div>
      <p>&#160;</p>
    </div>
    <p>
      <br clear='all' class='section'/>
    </p>
    <div class='WordSection3'>
      <p class='zzSTDTitle1'/>
      <div>
      <h1>
  1.
  <span style='mso-tab-count:1'>&#160; </span>
  Normative References
</h1>
        <p id='ISO712' class='NormRef'>
          ISO 712,
          <i>Cereals and cereal products</i>
        </p>
        <p id='ISO713' class='NormRef'>
          ISO 713,
          <i>Cereals and cereal products</i>
        </p>
      </div>
    </div>
  </body>
</html>

OUTPUT
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(word)
      end

    it "processes variant" do
          expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata>
    <language>en</language>
    <script>Latn</script>
    </bibdata>
    <preface>
        <clause id="A"><title><variant lang="en" script="Latn">ABC</variant><variant lang="fr" script="Latn">DEF</variant></title></clause>
        <clause id="B"><title><variant lang="de" script="Latn">GHI</variant><variant lang="es" script="Latn">JKL</variant></title></clause>
        <clause id="C"><title><variant lang="fr" script="Latn">ABC</variant><variant lang="en" script="Latn">DEF</variant></title></clause>
    </preface>
    </iso-standard>
    INPUT
        #{HTML_HDR}
        <br/>
      <div class='Section3' id='A'>
        <h1 class='IntroTitle'>ABC</h1>
          </div>
  <br/>
  <div class='Section3' id='B'>
    <h1 class='IntroTitle'>GHI</h1>
  </div>
  <br/>
  <div class='Section3' id='C'>
    <h1 class='IntroTitle'>DEF</h1>
  </div>
      <p class='zzSTDTitle1'/>
    </div>
  </body>
</html>
    OUTPUT
    end

it "cases xrefs" do
  expect(xmlpp(IsoDoc::PresentationXMLConvert.new({i18nyaml: "spec/assets/i18n.yaml"}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <clause id="A">
    <table id="B">
    </table>
    </clause>
    <clause id="C">
    <p>This is <xref target="A"/> and <xref target="B"/>.
    This is <xref target="A" case="capital"/> and <xref target="B" case="lowercase"/>.
    <xref target="A"/> is clause <em>initial.</em><br/>
    <xref target="A"/> is too.  </p>
    <p><xref target="A"/> is also.</p>
</clause>
</sections>
</iso-standard>
INPUT
<?xml version='1.0'?>
<iso-standard xmlns='http://riboseinc.com/isoxml'>
  <sections>
    <clause id='A'>
    <title>1.</title>
      <table id='B'>
        <name>Tabelo 1</name>
      </table>
    </clause>
    <clause id='C'>
    <title>2.</title>
      <p>
        This is 
        <xref target='A'>kla&#x16D;zo 1</xref>
         and 
        <xref target='B'>Tabelo 1</xref>
        . This is 
        <xref target='A' case='capital'>Kla&#x16D;zo 1</xref>
         and 
        <xref target='B' case='lowercase'>tabelo 1</xref>
        . 
        <xref target='A'>Kla&#x16D;zo 1</xref>
         is clause 
        <em>initial.</em>
        <br/>
        <xref target='A'>Kla&#x16D;zo 1</xref>
         is too. 
      </p>
      <p>
        <xref target='A'>Kla&#x16D;zo 1</xref>
         is also.
      </p>
    </clause>
  </sections>
</iso-standard>
OUTPUT
end

end
