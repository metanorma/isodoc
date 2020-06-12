require "spec_helper"

RSpec.describe IsoDoc do
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
      expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
        #{HTML_HDR}
        <br/>
             <div>
               <h1 class='ForewordTitle'>Foreword</h1>
               <p>
                 <ul>
                   <li>
                     [Term defined in <a href='#clause1'>Clause 2</a>]
                   </li>
                   <li>w[o]rd</li>
                   <li>
                     [Term defined in <a href='#ISO712'>ISO 712</a>]
                   </li>
                   <li>word</li>
                   <li>
                     [Term defined in <a href='#ISO712'>ISO 712, Clause 3.1, Figure a</a>]
                   </li>
                   <li>
                     [Term defined in <a href='#ISO712'>ISO 712, Clause 3.1; Figure b</a>]
                   </li>
                   <li>
                     <i>word</i>
                   </li>
                   <li>[Term defined in Termbase IEV, term ID 135-13-13]</li>
                   <li>
                     <i>word</i> word
                   </li>
                 </ul>
               </p>
             </div>
             <p class='zzSTDTitle1'/>
             <div>
               <h1>1.&#160; Normative references</h1>
               <p>
                 The following documents are referred to in the text in such a way that
                 some or all of their content constitutes requirements of this
                 document. For dated references, only the edition cited applies. For
                 undated references, the latest edition of the referenced document
                 (including any amendments) applies.
               </p>
               <p id='ISO712' class='NormRef'>
                 ISO 712, <i>Cereals and cereal products</i>
               </p>
             </div>
             <div id='clause1'>
               <h1>2.&#160; Clause 1</h1>
             </div>
           </div>
         </body>
       </html>
OUTPUT
    end

  it "processes embedded inline formatting" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <em><strong>&lt;</strong></em> <tt><link target="B"/></tt> <xref target="_http_1_1">Requirement <tt>/req/core/http</tt></xref> <eref type="inline" bibitemid="ISO712" citeas="ISO 712">Requirement <tt>/req/core/http</tt></eref> <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><locality type="section"><referenceFrom>3.1</referenceFrom></locality></eref>
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
       <i><b>&lt;</b></i> <tt><a href="B">B</a></tt> <a href="#_http_1_1">Requirement <tt>/req/core/http</tt></a>  <a href="#ISO712">Requirement <tt>/req/core/http</tt></a> <a href="#ISO712">ISO 712, Section 3.1</a>
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
                 <h1>1.&#160; Normative references</h1>
                 <p id="ISO712" class="NormRef">ISO 712, <i> Cereals and cereal products</i></p>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

  it "processes eref content" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
           <a href="#ISO712">ISO 712, </a>
           <a href="#ISO712">ISO 712, Prelude 7</a>
           <a href="#ISO712">A</a>
           <a href='#ISO712'>ISO 712</a>
           <a href='#ISO712'>ISO 712, Clause 1</a>
           </p>
               </div>
               <p class="zzSTDTitle1"/>
               <div>
                 <h1>1.&#160; Normative references</h1>
                 <p id="ISO712" class="NormRef">ISO 712, <i> Cereals and cereal products</i></p>
               </div>
             </div>
           </body>
       </html>
    OUTPUT
  end

    it "processes eref content pointing to reference with citation URL" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
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
    </references>
    </bibliography>
    </iso-standard>
    INPUT
        #{HTML_HDR}
      <br/>
      <div>
        <h1 class='ForewordTitle'>Foreword</h1>
        <p>
          <a href='http://www.example.com'>ISO 712</a>
          <a href='http://www.example.com'>ISO 712</a>
          <a href='http://www.example.com'>ISO 712, Table 1</a>
          <a href='http://www.example.com'>ISO 712, Table 1</a>
          <a href='http://www.example.com'>ISO 712, Table 1; Clause 1</a>
          <a href='http://www.example.com'>ISO 712, Table 1&#8211;1</a>
          <a href='http://www.example.com'>ISO 712, Clause 1, Table 1</a>
          <a href='http://www.example.com'>ISO 712, Clause 1</a>
          <a href='http://www.example.com'>ISO 712, Clause 1.5</a>
          <a href='http://www.example.com'>A</a>
          <a href='http://www.example.com'>ISO 712, </a>
          <a href='http://www.example.com'>ISO 712, Prelude 7</a>
          <a href='http://www.example.com'>A</a>
          <a href='http://www.example.com#xyz'>ISO 712</a>
          <a href='http://www.example.com#xyz'>ISO 712, Clause 1</a>
        </p>
      </div>
      <p class='zzSTDTitle1'/>
      <div>
        <h1>1.&#160; Normative references</h1>
        <p id='ISO712' class='NormRef'>
          ISO 712,
          <i>Cereals and cereal products</i>
        </p>
      </div>
    </div>
  </body>
</html>
OUTPUT
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
  expect(xmlpp(IsoDoc::HtmlConvert.new({i18nyaml: "spec/assets/i18n.yaml"}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
        #{HTML_HDR}
      <p class='zzSTDTitle1'/>
      <div id='A'>
        <h1>1.&#160; </h1>
        <p class='TableTitle' style='text-align:center;'>Tabelo 1</p>
        <table id='B' class='MsoISOTable' style='border-width:1px;border-spacing:0;'/>
      </div>
      <div id='C'>
        <h1>2.&#160; </h1>
        <p>
          This is
          <a href='#A'>kla&#365;zo 1</a>
           and
          <a href='#B'>Tabelo 1</a>
          . This is
          <a href='#A'>Kla&#365;zo 1</a>
           and
          <a href='#B'>tabelo 1</a>
          .
          <a href='#A'>Kla&#365;zo 1</a>
           is clause
          <i>initial.</i>
          <br/>
          <a href='#A'>Kla&#365;zo 1</a>
           is too.
        </p>
        <p>
          <a href='#A'>Kla&#365;zo 1</a>
           is also.
        </p>
      </div>
    </div>
  </body>
</html>
OUTPUT
end

end
