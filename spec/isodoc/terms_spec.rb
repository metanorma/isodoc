require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML terms (PresentationXML)" do
    expect(xmlpp(IsoDoc::PresentationXMLConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>
    <p>For the purposes of this document, the following terms and definitions apply.</p>

<term id="paddy1"><preferred>paddy</preferred>
<domain>rice</domain>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
<termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892"  keep-with-next="true" keep-lines-together="true">
  <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
  <ul>
  <li>A</li>
  </ul>
</termexample>
<termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
  <ul>
  <li>A</li>
  </ul>
</termexample>

<termsource status="modified">
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
    <modification>
    <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
  </modification>
</termsource>

<termsource status='identical'>
    <origin citeas=''>
      <termref base='IEV' target='xyz'>t1</termref>
    </origin>
  </termsource>

  <termsource status='modified'>
    <origin citeas=''>
      <termref base='IEV' target='xyz'/>
    </origin>
    <modification>
      <p id='_'>with adjustments</p>
    </modification>
  </termsource>



</term>

<term id="paddy"><preferred>paddy</preferred><admitted>paddy rice</admitted>
<admitted>rough rice</admitted>
<deprecates>cargo rice</deprecates>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
<termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
  <ul>
  <li>A</li>
  </ul>
</termexample>
<termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e"  keep-with-next="true" keep-lines-together="true">
  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
<ul><li>A</li></ul>
  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termsource status="identical">
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
</termsource></term>
</terms>
</sections>
</iso-standard>
    INPUT
    <?xml version='1.0'?>
       <iso-standard xmlns='http://riboseinc.com/isoxml'>
         <sections>
           <terms id='_terms_and_definitions' obligation='normative'>
             <title>Terms and Definitions</title>
             <p>For the purposes of this document, the following terms and definitions apply.</p>
             <term id='paddy1'>
               <preferred>paddy</preferred>
               <domain>rice</domain>
               <definition>
                 <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
               </definition>
               <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f892' keep-with-next='true' keep-lines-together='true'>
                 <name>EXAMPLE 1</name>
                 <p id='_65c9a509-9a89-4b54-a890-274126aeb55c'>Foreign seeds, husks, bran, sand, dust.</p>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f894'>
                 <name>EXAMPLE 2</name>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termsource status='modified'>
                 <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'>
                   <locality type='clause'>
                     <referenceFrom>3.1</referenceFrom>
                   </locality>
                 </origin>
                 <modification>
                   <p id='_e73a417d-ad39-417d-a4c8-20e4e2529489'>
                     The term "cargo rice" is shown as deprecated, and Note 1 to entry
                     is not included here
                   </p>
                 </modification>
               </termsource>
               <termsource status='identical'>
                 <origin citeas=''>
                   <termref base='IEV' target='xyz'>t1</termref>
                 </origin>
               </termsource>
               <termsource status='modified'>
                 <origin citeas=''>
                   <termref base='IEV' target='xyz'/>
                 </origin>
                 <modification>
                   <p id='_'>with adjustments</p>
                 </modification>
               </termsource>
             </term>
             <term id='paddy'>
               <preferred>paddy</preferred>
               <admitted>paddy rice</admitted>
               <admitted>rough rice</admitted>
               <deprecates>cargo rice</deprecates>
               <definition>
                 <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
               </definition>
               <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f893'>
                 <name>EXAMPLE</name>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74e' keep-with-next='true' keep-lines-together='true'>
                 <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                   The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.
                 </p>
               </termnote>
               <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74f'>
                 <ul>
                   <li>A</li>
                 </ul>
                 <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                   The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.
                 </p>
               </termnote>
               <termsource status='identical'>
                 <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'>
                   <locality type='clause'>
                     <referenceFrom>3.1</referenceFrom>
                   </locality>
                 </origin>
               </termsource>
             </term>
           </terms>
         </sections>
       </iso-standard>
OUTPUT
  end

  it "processes IsoXML terms (HTML)" do
    expect(xmlpp(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
       <iso-standard xmlns='http://riboseinc.com/isoxml'>
         <sections>
           <terms id='_terms_and_definitions' obligation='normative'>
             <title>Terms and Definitions</title>
             <p>For the purposes of this document, the following terms and definitions apply.</p>
             <term id='paddy1'>
               <preferred>paddy</preferred>
               <domain>rice</domain>
               <definition>
                 <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
               </definition>
               <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f892' keep-with-next='true' keep-lines-together='true'>
                 <name>EXAMPLE 1</name>
                 <p id='_65c9a509-9a89-4b54-a890-274126aeb55c'>Foreign seeds, husks, bran, sand, dust.</p>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f894'>
                 <name>EXAMPLE 2</name>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termsource status='modified'>
                 <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'>
                   <locality type='clause'>
                     <referenceFrom>3.1</referenceFrom>
                   </locality>
                 </origin>
                 <modification>
                   <p id='_e73a417d-ad39-417d-a4c8-20e4e2529489'>The term "cargo rice" is shown as deprecated, and Note 1 to entry
                     is not included here
                   </p>
                 </modification>
               </termsource>
               <termsource status='identical'>
                 <origin citeas=''>
                   <termref base='IEV' target='xyz'>t1</termref>
                 </origin>
               </termsource>
               <termsource status='modified'>
                 <origin citeas=''>
                   <termref base='IEV' target='xyz'/>
                 </origin>
                 <modification>
                   <p id='_'>with adjustments</p>
                 </modification>
               </termsource>
             </term>
             <term id='paddy'>
               <preferred>paddy</preferred>
               <admitted>paddy rice</admitted>
               <admitted>rough rice</admitted>
               <deprecates>cargo rice</deprecates>
               <definition>
                 <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
               </definition>
               <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f893'>
                 <name>EXAMPLE</name>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74e' keep-with-next='true' keep-lines-together='true'>
                 <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                   The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.
                 </p>
               </termnote>
               <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74f'>
                 <ul>
                   <li>A</li>
                 </ul>
                 <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                   The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.
                 </p>
               </termnote>
               <termsource status='identical'>
                 <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'>
                   <locality type='clause'>
                     <referenceFrom>3.1</referenceFrom>
                   </locality>
                 </origin>
               </termsource>
             </term>
           </terms>
         </sections>
       </iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="_terms_and_definitions"><h1>1.&#160; Terms and Definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p class="TermNum" id="paddy1">1.1.</p><p class="Terms" style="text-align:left;">paddy</p>

       <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&lt;rice&gt; rice retaining its husk after threshing</p>
       <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f892" class="example"  style='page-break-after: avoid;page-break-inside: avoid;'><p class="example-title">EXAMPLE 1</p>
         <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
         <ul>
         <li>A</li>
         </ul>
       </div>
       <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f894" class="example"><p class="example-title">EXAMPLE 2</p>
         <ul>
         <li>A</li>
         </ul>
       </div>

       <p>[TERMREF]
         <a href="#ISO7301">ISO 7301:2011, Clause 3.1</a>
           [MODIFICATION]The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here
       [/TERMREF]</p>
       <p>[TERMREF] Termbase IEV, term ID xyz [/TERMREF]</p>
<p>[TERMREF] Termbase IEV, term ID xyz [MODIFICATION]with adjustments [/TERMREF]</p>
<p class="TermNum" id="paddy">1.2.</p><p class="Terms" style="text-align:left;">paddy</p><p class="AltTerms" style="text-align:left;">paddy rice</p>
       <p class="AltTerms" style="text-align:left;">rough rice</p>
       <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
       <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
       <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f893" class="example"><p class="example-title">EXAMPLE</p>
         <ul>
         <li>A</li>
         </ul>
       </div>
       <div class="Note" id='_671a1994-4783-40d0-bc81-987d06ffb74e' style='page-break-after: avoid;page-break-inside: avoid;'><p>Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
       <div class="Note" id='_671a1994-4783-40d0-bc81-987d06ffb74f'><p>Note 2 to entry: <ul><li>A</li></ul><p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></p></div>
       <p>[TERMREF]
         <a href="#ISO7301">ISO 7301:2011, Clause 3.1</a>
       [/TERMREF]</p></div>
             </div>
           </body>
       </html>
OUTPUT
  end
  
  it "processes IsoXML terms (Word)" do
    expect(xmlpp(IsoDoc::WordConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
       <iso-standard xmlns='http://riboseinc.com/isoxml'>
         <sections>
           <terms id='_terms_and_definitions' obligation='normative'>
             <title>Terms and Definitions</title>
             <p>For the purposes of this document, the following terms and definitions apply.</p>
             <term id='paddy1'>
               <preferred>paddy</preferred>
               <domain>rice</domain>
               <definition>
                 <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
               </definition>
               <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f892' keep-with-next='true' keep-lines-together='true'>
                 <name>EXAMPLE 1</name>
                 <p id='_65c9a509-9a89-4b54-a890-274126aeb55c'>Foreign seeds, husks, bran, sand, dust.</p>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f894'>
                 <name>EXAMPLE 2</name>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termsource status='modified'>
                 <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'>
                   <locality type='clause'>
                     <referenceFrom>3.1</referenceFrom>
                   </locality>
                 </origin>
                 <modification>
                   <p id='_e73a417d-ad39-417d-a4c8-20e4e2529489'>The term "cargo rice" is shown as deprecated, and Note 1 to entry
                     is not included here
                   </p>
                 </modification>
               </termsource>
               <termsource status='identical'>
                 <origin citeas=''>
                   <termref base='IEV' target='xyz'>t1</termref>
                 </origin>
               </termsource>
               <termsource status='modified'>
                 <origin citeas=''>
                   <termref base='IEV' target='xyz'/>
                 </origin>
                 <modification><p id='_'>with adjustments</p></modification>
               </termsource>
             </term>
             <term id='paddy'>
               <preferred>paddy</preferred>
               <admitted>paddy rice</admitted>
               <admitted>rough rice</admitted>
               <deprecates>cargo rice</deprecates>
               <definition>
                 <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
               </definition>
               <termexample id='_bd57bbf1-f948-4bae-b0ce-73c00431f893'>
                 <name>EXAMPLE</name>
                 <ul>
                   <li>A</li>
                 </ul>
               </termexample>
               <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74e' keep-with-next='true' keep-lines-together='true'>
                 <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                   The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.
                 </p>
               </termnote>
               <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74f'>
                 <ul>
                   <li>A</li>
                 </ul>
                 <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                   The starch of waxy rice consists almost entirely of amylopectin. The
                   kernels have a tendency to stick together after cooking.
                 </p>
               </termnote>
               <termsource status='identical'>
                 <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'>
                   <locality type='clause'>
                     <referenceFrom>3.1</referenceFrom>
                   </locality>
                 </origin>
               </termsource>
             </term>
           </terms>
         </sections>
       </iso-standard>
    INPUT
    #{WORD_HDR}
             <p class="zzSTDTitle1"/>
             <div id="_terms_and_definitions"><h1>1.<span style="mso-tab-count:1">&#160; </span>Terms and Definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p class="TermNum" id="paddy1">1.1.</p><p class="Terms" style="text-align:left;">paddy</p>

       <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&lt;rice&gt; rice retaining its husk after threshing</p>
       <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f892" class="example"  style='page-break-after: avoid;page-break-inside: avoid;'><p class="example-title">EXAMPLE 1</p>
         <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
         <ul>
         <li>A</li>
         </ul>
       </div>
       <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f894" class="example"><p class="example-title">EXAMPLE 2</p>
         <ul>
         <li>A</li>
         </ul>
       </div>

       <p>[TERMREF]
         <a href="#ISO7301">ISO 7301:2011, Clause 3.1</a>
           [MODIFICATION]The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here
       [/TERMREF]</p>
       <p>[TERMREF] Termbase IEV, term ID xyz [/TERMREF]</p>
<p>[TERMREF] Termbase IEV, term ID xyz [MODIFICATION]with adjustments [/TERMREF]</p>
<p class="TermNum" id="paddy">1.2.</p><p class="Terms" style="text-align:left;">paddy</p><p class="AltTerms" style="text-align:left;">paddy rice</p>
       <p class="AltTerms" style="text-align:left;">rough rice</p>
       <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
       <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
       <div id="_bd57bbf1-f948-4bae-b0ce-73c00431f893" class="example"><p class="example-title">EXAMPLE</p>
         <ul>
         <li>A</li>
         </ul>
       </div>
       <div id='_671a1994-4783-40d0-bc81-987d06ffb74e' class="Note"  style='page-break-after: avoid;page-break-inside: avoid;'><p class="Note">Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
       <div id='_671a1994-4783-40d0-bc81-987d06ffb74f' class="Note"><p class="Note">Note 2 to entry: <ul><li>A</li></ul><p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></p></div>
       <p>[TERMREF]
         <a href="#ISO7301">ISO 7301:2011, Clause 3.1</a>
       [/TERMREF]</p></div>
           </div>
         </body>
       </html>

OUTPUT
  end
end
