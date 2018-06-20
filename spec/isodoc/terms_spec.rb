require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML terms" do
    expect(IsoDoc::HtmlConvert.new({}).convert("test", <<~"INPUT", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <terms id="_terms_and_definitions" obligation="normative"><title>Terms and Definitions</title>

<term id="paddy1"><preferred>paddy</preferred>
<domain>rice</domain>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
<termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
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
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301: 2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
    <modification>
    <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
  </modification>
</termsource></term>

<term id="paddy"><preferred>paddy</preferred><admitted>paddy rice</admitted>
<admitted>rough rice</admitted>
<deprecates>cargo rice</deprecates>
<definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
<termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
  <ul>
  <li>A</li>
  </ul>
</termexample>
<termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
<ul><li>A</li></ul>
  <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
</termnote>
<termsource status="identical">
  <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301: 2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
</termsource></term>
</terms>
</sections>
</iso-standard>
    INPUT
    #{HTML_HDR}
               <p class="zzSTDTitle1"/>
               <div id="_terms_and_definitions"><h1>1.&#160; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p>ISO and IEC maintain terminological databases for use in
       standardization at the following addresses:</p>

       <ul>
       <li> <p>ISO Online browsing platform: available at
         <a href="http://www.iso.org/obp">http://www.iso.org/obp</a></p> </li>
       <li> <p>IEC Electropedia: available at
         <a href="http://www.electropedia.org">http://www.electropedia.org</a>
       </p> </li> </ul>
       <p class="TermNum" id="paddy1">1.1</p><p class="Terms" style="text-align:left;">paddy</p>

       <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&lt;rice&gt; rice retaining its husk after threshing</p>
       <table id="_bd57bbf1-f948-4bae-b0ce-73c00431f892" class="example"><tr><td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE 1</td><td valign="top" class="example">
         <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
         <ul>
         <li>A</li>
         </ul>
       </td></tr></table>
       <table id="_bd57bbf1-f948-4bae-b0ce-73c00431f894" class="example"><tr><td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE 2</td><td valign="top" class="example">
         <ul>
         <li>A</li>
         </ul>
       </td></tr></table>

       <p>[TERMREF]
         <a href="#ISO7301">ISO 7301: 2011, 3.1</a>
           [MODIFICATION]The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here
       [/TERMREF]</p><p class="TermNum" id="paddy">1.2</p><p class="Terms" style="text-align:left;">paddy</p><p class="AltTerms" style="text-align:left;">paddy rice</p>
       <p class="AltTerms" style="text-align:left;">rough rice</p>
       <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
       <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p>
       <table id="_bd57bbf1-f948-4bae-b0ce-73c00431f893" class="example"><tr><td width="110pt" valign="top" class="example_label" style="width:82.8pt;padding:.75pt .75pt .75pt .75pt">EXAMPLE 1</td><td valign="top" class="example">
         <ul>
         <li>A</li>
         </ul>
       </td></tr></table>
       <div class="Note"><p class="Note">Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
       <div class="Note"><p class="Note">Note 2 to entry: <ul><li>A</li></ul><p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></p></div>
       <p>[TERMREF]
         <a href="#ISO7301">ISO 7301: 2011, 3.1</a>
       [/TERMREF]</p></div>
             </div>
           </body>
         </head>
       </html>
OUTPUT
  end
end
