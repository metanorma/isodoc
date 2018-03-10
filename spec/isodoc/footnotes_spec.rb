require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML footnotes" do
    expect(IsoDoc::Convert.new({}).convert_file(<<~"INPUT", "test", true)).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <foreword>
    <p>A.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>B.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>C.<fn reference="1">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
</fn></p>
    </foreword>
    </iso-standard>
    INPUT
           <html xmlns:epub="http://www.idpf.org/2007/ops">
         <head>
           <title>test</title>
           <body lang="EN-US" link="blue" vlink="#954F72">
             <div class="WordSection1">
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection2">
               <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p>A.<a href="#ftn2" epub:type="footnote"><sup>2</sup></a></p>
                 <p>B.<a href="#ftn2" epub:type="footnote"><sup>2</sup></a></p>
                 <p>C.<a href="#ftn1" epub:type="footnote"><sup>1</sup></a></p>
               </div>
               <p>&#160;</p>
             </div>
             <br clear="all" class="section"/>
             <div class="WordSection3">
               <p class="zzSTDTitle1"/>
               <aside id="ftn2">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
       </aside>
               <aside id="ftn1">
         <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
       </aside>
             </div>
           </body>
         </head>
       </html>
    OUTPUT
    end
end
