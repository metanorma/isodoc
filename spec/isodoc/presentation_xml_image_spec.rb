require "spec_helper"

RSpec.describe IsoDoc do
  it "duplicates EMF and SVG files" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
           <clause id='A' inline-header='false' obligation='normative'>
             <title>Clause</title>
             <figure id="B">
               <image src="spec/assets/odf.svg" mimetype="image/svg+xml" alt="1"/>
               <image src="spec/assets/odf.emf" mimetype="image/x-emf" alt="2"/>
               <image src="data:image/svg+xml;charset=utf-8;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIj48Y2lyY2xlIGZpbGw9IiMwMDkiIHI9IjQ1IiBjeD0iNTAiIGN5PSI1MCIvPjxwYXRoIGQ9Ik0zMywyNkg3OEEzNywzNywwLDAsMSwzMyw4M1Y1N0g1OVY0M0gzM1oiIGZpbGw9IiNGRkYiLz48L3N2Zz4=" mimetype="image/svg+xml" alt="3"/>
               <image src="data:application/x-msmetafile;base64,AQAAAMgAAAAAAAAAAAAAAPsEAAD7BAAAAAAAAAAAAACLCgAAiwoAACBFTUYAAAEAJAQAACgAAAACAAAALgAAAGwAAAAAAAAA3ScAAH0zAADYAAAAFwEAAAAAAAAAAAAAAAAAAMBLAwDYQQQASQBuAGsAcwBjAGEAcABlACAAMQAuADAAIAAoADQAMAAzADUAYQA0AGYALAAgADIAMAAyADAALQAwADUALQAwADEAKQAgAAAAbwBkAGYALgBlAG0AZgAAAAAAAAARAAAADAAAAAEAAAAkAAAAJAAAAAAAgD8AAAAAAAAAAAAAgD8AAAAAAAAAAAIAAABGAAAALAAAACAAAABTY3JlZW49MTAyMDV4MTMxODFweCwgMjE2eDI3OW1tAEYAAAAwAAAAIwAAAERyYXdpbmc9MTAwLjB4MTAwLjBweCwgMjYuNXgyNi41bW0AABIAAAAMAAAAAQAAABMAAAAMAAAAAgAAABYAAAAMAAAAGAAAABgAAAAMAAAAAAAAABQAAAAMAAAADQAAACcAAAAYAAAAAQAAAAAAAAAAAJkABgAAACUAAAAMAAAAAQAAADsAAAAIAAAAGwAAABAAAACkBAAAcQIAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACkBAAAqAMAAKgDAACkBAAAcQIAAKQEAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAOgEAAKQEAAA/AAAAqAMAAD8AAABxAgAABQAAADQAAAAAAAAAAAAAAP//////////AwAAAD8AAAA6AQAAOgEAAD8AAABxAgAAPwAAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAACoAwAAPwAAAKQEAAA6AQAApAQAAHECAAA9AAAACAAAADwAAAAIAAAAPgAAABgAAAAAAAAAAAAAAP//////////JQAAAAwAAAAFAACAKAAAAAwAAAABAAAAJwAAABgAAAABAAAAAAAAAP///wAGAAAAJQAAAAwAAAABAAAAOwAAAAgAAAAbAAAAEAAAAJ0BAABFAQAANgAAABAAAADPAwAARQEAAAUAAAA0AAAAAAAAAAAAAAD//////////wMAAABfBAAA7QEAAGQEAADjAgAA2wMAAJEDAAAFAAAANAAAAAAAAAAAAAAA//////////8DAAAAUgMAAD4EAABhAgAAcwQAAJ0BAAAOBAAANgAAABAAAACdAQAAyQIAADYAAAAQAAAA4gIAAMkCAAA2AAAAEAAAAOICAAAaAgAANgAAABAAAACdAQAAGgIAAD0AAAAIAAAAPAAAAAgAAAA+AAAAGAAAAAAAAAAAAAAA//////////8lAAAADAAAAAUAAIAoAAAADAAAAAEAAAAOAAAAFAAAAAAAAAAAAAAAJAQAAA==" mimetype="image/x-emf" alt="4"/>
             </figure>
           </clause>
         </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <figure id="B" autonum="1">
         <fmt-name id="_">
            <span class="fmt-caption-label">
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B">1</semx>
            </span>
         </fmt-name>
         <fmt-xref-label>
            <span class="fmt-element-name">Figure</span>
            <semx element="autonum" source="B">1</semx>
         </fmt-xref-label>
         <image src="spec/assets/odf.svg" mimetype="image/svg+xml" alt="1">
            <emf src="spec/assets/odf.emf"/>
         </image>
         <image src="" mimetype="image/svg+xml" alt="2">
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000" preserveaspectratio="xMidYMin slice">
               <g transform="translate(-0.0000, -0.0000)">
                  <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
                     <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
                     <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
                  </g>
               </g>
            </svg>
            <emf src="data:image/emf;base64"/>
         </image>
         <image src="" mimetype="image/svg+xml" alt="3" height="" width="">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveaspectratio="xMidYMin slice">
               <circle fill="#009" r="45" cx="50" cy="50"/>
               <path d="M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z" fill="#FFF"/>
            </svg>
            <emf src="data:image/emf;base64"/>
         </image>
         <image src="" mimetype="image/svg+xml" alt="4">
            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000" preserveaspectratio="xMidYMin slice">
               <g transform="translate(-0.0000, -0.0000)">
                  <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
                     <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
                     <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
                  </g>
               </g>
            </svg>
            <emf src="data:application/x-msmetafile;base64"/>
         </image>
      </figure>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html", doc: "doc" }))
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
      .gsub(%r{"data:image/emf;base64,[^"]+"},
            '"data:image/emf;base64"')
      .gsub(%r{"data:application/x-msmetafile;base64,[^"]+"},
            '"data:application/x-msmetafile;base64"'))))
      .to be_equivalent_to (Canon.format_xml(output))

    output = <<~OUTPUT
      <figure id="B" autonum="1">
        <fmt-name id="_">
           <span class="fmt-caption-label">
              <span class="fmt-element-name">Figure</span>
              <semx element="autonum" source="B">1</semx>
           </span>
        </fmt-name>
        <fmt-xref-label>
           <span class="fmt-element-name">Figure</span>
           <semx element="autonum" source="B">1</semx>
        </fmt-xref-label>
             <image src="spec/assets/odf.svg" mimetype="image/svg+xml" alt="1"/>
             <image src="" mimetype="image/svg+xml" alt="2">
               <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000" preserveaspectratio="xMidYMin slice">
                 <g transform="translate(-0.0000, -0.0000)">
                   <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
                     <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
                     <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
                   </g>
                 </g>
               </svg>
               <emf src="data:image/emf;base64"/>
             </image>
             <image src="" mimetype="image/svg+xml" alt="3">
               <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveaspectratio="xMidYMin slice">
                 <circle fill="#009" r="45" cx="50" cy="50"/>
                 <path d="M33,26H78A37,37,0,0,1,33,83V57H59V43H33Z" fill="#FFF"/>
               </svg>
             </image>
             <image src="" mimetype="image/svg+xml" alt="4">
               <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="1275.0000" height="1275.0000" preserveaspectratio="xMidYMin slice">
                 <g transform="translate(-0.0000, -0.0000)">
                   <g transform="matrix(1.0000 0.0000 0.0000 1.0000 0.0000 0.0000)">
                     <path d="M 1188.0000,625.0000 C 1188.0000,936.0000 936.0000,1188.0000 625.0000,1188.0000 C 314.0000,1188.0000 63.0000,936.0000 63.0000,625.0000 C 63.0000,314.0000 314.0000,63.0000 625.0000,63.0000 C 936.0000,63.0000 1188.0000,314.0000 1188.0000,625.0000 Z " fill="#000099" stroke="none"/>
                     <path d="M 413.0000,325.0000 L 975.0000,325.0000 C 1119.0000,493.0000 1124.0000,739.0000 987.0000,913.0000 C 850.0000,1086.0000 609.0000,1139.0000 413.0000,1038.0000 L 413.0000,713.0000 L 738.0000,713.0000 L 738.0000,538.0000 L 413.0000,538.0000 Z " fill="#FFFFFF" stroke="none"/>
                   </g>
                 </g>
               </svg>
               <emf src="data:application/x-msmetafile;base64"/>
             </image>
           </figure>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options.merge(output_formats: { html: "html" }))
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .sub(%r{<metanorma-extension>.*</metanorma-extension>}m, "")
      .gsub(%r{"data:image/emf;base64,[^"]+"},
            '"data:image/emf;base64"')
      .gsub(%r{"data:application/x-msmetafile;base64,[^"]+"},
            '"data:application/x-msmetafile;base64"'))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "converts EPS to SVG files" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
      <sections>
       <clause id='A' inline-header='false' obligation='normative'>
       <title>Clause</title>
       <figure id="B">
       <image mimetype="application/postscript" alt="3">%!PS-Adobe-3.0 EPSF-3.0
      %%Document-Fonts: Times-Roman
      %%Title: circle.eps
      %%Creator: PS_Write.F
      %%CreationDate: 02-Aug-99
      %%Pages: 1
      %%BoundingBox:   36   36  576  756
      %%LanguageLevel: 1
      %%EndComments
      %%BeginProlog
      %%EndProlog
      /inch {72 mul} def
      /Palatino-Roman findfont
      1.00 inch scalefont
      setfont
       0.0000 0.0000 0.0000 setrgbcolor
      %% Page:     1    1
      save
        63 153 moveto
       newpath
        63 153 moveto
       549 153 lineto
       stroke
       newpath
       549 153 moveto
       549 639 lineto
       stroke
       newpath
       549 639 moveto
        63 639 lineto
       stroke
       newpath
        63 639 moveto
        63 153 lineto
       stroke
       newpath
       360 261 108   0 360 arc
       closepath stroke
       newpath
       361 357 moveto
       358 358 lineto
       353 356 lineto
       348 353 lineto
       342 347 lineto
       336 340 lineto
       329 331 lineto
       322 321 lineto
       315 309 lineto
       307 296 lineto
       300 283 lineto
       292 268 lineto
       285 253 lineto
       278 237 lineto
       271 222 lineto
       266 206 lineto
       260 191 lineto
       256 177 lineto
       252 164 lineto
       249 152 lineto
       247 141 lineto
       246 131 lineto
       246 123 lineto
       247 117 lineto
       248 113 lineto
       251 111 lineto
       254 110 lineto
       259 112 lineto
       264 115 lineto
       270 121 lineto
       276 128 lineto
       283 137 lineto
       290 147 lineto
       297 159 lineto
       305 172 lineto
       312 185 lineto
       320 200 lineto
       327 215 lineto
       334 231 lineto
       341 246 lineto
       346 262 lineto
       352 277 lineto
       356 291 lineto
       360 304 lineto
       363 316 lineto
       365 327 lineto
       366 337 lineto
       366 345 lineto
       365 351 lineto
       364 355 lineto
       361 357 lineto
       stroke
       newpath
       171 261 moveto
       171 531 lineto
       stroke
       newpath
       198 261 moveto
       198 531 lineto
       stroke
       newpath
       225 261 moveto
       225 531 lineto
       stroke
       newpath
       252 261 moveto
       252 531 lineto
       stroke
       newpath
       279 261 moveto
       279 531 lineto
       stroke
       newpath
       306 261 moveto
       306 531 lineto
       stroke
       newpath
       333 261 moveto
       333 531 lineto
       stroke
       newpath
       360 261 moveto
       360 531 lineto
       stroke
       newpath
       387 261 moveto
       387 531 lineto
       stroke
       newpath
       414 261 moveto
       414 531 lineto
       stroke
       newpath
       441 261 moveto
       441 531 lineto
       stroke
       newpath
       171 261 moveto
       441 261 lineto
       stroke
       newpath
       171 288 moveto
       441 288 lineto
       stroke
       newpath
       171 315 moveto
       441 315 lineto
       stroke
       newpath
       171 342 moveto
       441 342 lineto
       stroke
       newpath
       171 369 moveto
       441 369 lineto
       stroke
       newpath
       171 396 moveto
       441 396 lineto
       stroke
       newpath
       171 423 moveto
       441 423 lineto
       stroke
       newpath
       171 450 moveto
       441 450 lineto
       stroke
       newpath
       171 477 moveto
       441 477 lineto
       stroke
       newpath
       171 504 moveto
       441 504 lineto
       stroke
       newpath
       171 531 moveto
       441 531 lineto
       stroke
       newpath
       306 396   5   0 360 arc
       closepath stroke
       0.0000 1.0000 0.0000 setrgbcolor
       newpath
       387 477  54   0  90 arc
       stroke
       171 261 moveto
       0.0000 0.0000 0.0000 setrgbcolor
      /Palatino-Roman findfont
         0.250 inch scalefont
      setfont
      (This is "circle.plot".) show
       171 342 moveto
      /Palatino-Roman findfont
         0.125 inch scalefont
      setfont
      (This is small print.) show
      restore showpage
      %%Trailer
      </image>
                   </figure>
                 </clause>
               </sections>
            </iso-standard>
    INPUT
    output = <<~OUTPUT
      <figure id="B" autonum="1">
         <fmt-name id="_">
            <span class="fmt-caption-label">
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B">1</semx>
            </span>
         </fmt-name>
         <fmt-xref-label>
            <span class="fmt-element-name">Figure</span>
            <semx element="autonum" source="B">1</semx>
         </fmt-xref-label>
         <image mimetype="image/svg+xml" alt="3" src="_.svg"/>
      </figure>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .gsub(%r{src="[^"]+?\.emf"}, 'src="_.emf"')
      .gsub(%r{src="[^"]+?\.svg"}, 'src="_.svg"'))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "converts file EPS to SVG" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <bibdata/>
        <sections>
          <clause id='A' inline-header='false' obligation='normative'>
            <title>Clause</title>
            <figure id="B">
              <image mimetype="application/postscript" alt="3" src="spec/assets/img.eps"/>
            </figure>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <figure id="B" autonum="1">
         <fmt-name id="_">
            <span class="fmt-caption-label">
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B">1</semx>
            </span>
         </fmt-name>
         <fmt-xref-label>
            <span class="fmt-element-name">Figure</span>
            <semx element="autonum" source="B">1</semx>
         </fmt-xref-label>
         <image mimetype="image/svg+xml" alt="3" src="_.svg"/>
      </figure>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:figure[@id = 'B']").to_xml
      .gsub(%r{src="[^"]+?\.svg"}, 'src="_.svg"'))))
      .to be_equivalent_to(output)
  end

  it "captions embedded figures" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
       <clause id="A" inline-header="false" obligation="normative">
       <title>Section</title>
       <figure id="B1">
       <name>First</name>
       </figure>
       <example id="C1">
       <figure id="B2">
       <name>Second</name>
       </figure>
       </example>
       <example id="C2">
       <figure id="B4" unnumbered="true">
       <name>Unnamed</name>
       </figure>
       </example>
       <figure id="B3">
       <name>Third</name>
       </figure>
       </clause>
         </sections>
       </iso-standard>
    INPUT
    presxml = <<~OUTPUT
      <clause id="A" inline-header="false" obligation="normative" displayorder="2">
         <title id="_">Section</title>
         <fmt-title id="_" depth="1">
            <span class="fmt-caption-label">
               <semx element="autonum" source="A">1</semx>
               <span class="fmt-autonum-delim">.</span>
            </span>
            <span class="fmt-caption-delim">
               <tab/>
            </span>
            <semx element="title" source="_">Section</semx>
         </fmt-title>
         <fmt-xref-label>
            <span class="fmt-element-name">Clause</span>
            <semx element="autonum" source="A">1</semx>
         </fmt-xref-label>
         <figure id="B1" autonum="1">
            <name id="_">First</name>
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="B1">1</semx>
               </span>
               <span class="fmt-caption-delim">\\u00a0— </span>
               <semx element="name" source="_">First</semx>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B1">1</semx>
            </fmt-xref-label>
         </figure>
         <example id="C1" autonum="1">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">EXAMPLE</span>
                  <semx element="autonum" source="C1">1</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Example</span>
               <semx element="autonum" source="C1">1</semx>
            </fmt-xref-label>
            <fmt-xref-label container="A">
               <span class="fmt-xref-container">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="A">1</semx>
               </span>
               <span class="fmt-comma">,</span>
               <span class="fmt-element-name">Example</span>
               <semx element="autonum" source="C1">1</semx>
            </fmt-xref-label>
            <figure id="B2" autonum="2">
               <name id="_">Second</name>
               <fmt-name id="_">
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Figure</span>
                     <semx element="autonum" source="B2">2</semx>
                  </span>
                  <span class="fmt-caption-delim">\\u00a0— </span>
                  <semx element="name" source="_">Second</semx>
               </fmt-name>
               <fmt-xref-label>
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="B2">2</semx>
               </fmt-xref-label>
            </figure>
         </example>
         <example id="C2" autonum="2">
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">EXAMPLE</span>
                  <semx element="autonum" source="C2">2</semx>
               </span>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Example</span>
               <semx element="autonum" source="C2">2</semx>
            </fmt-xref-label>
            <fmt-xref-label container="A">
               <span class="fmt-xref-container">
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="A">1</semx>
               </span>
               <span class="fmt-comma">,</span>
               <span class="fmt-element-name">Example</span>
               <semx element="autonum" source="C2">2</semx>
            </fmt-xref-label>
            <figure id="B4" unnumbered="true">
               <name id="_">Unnamed</name>
               <fmt-name id="_">
                  <semx element="name" source="_">Unnamed</semx>
               </fmt-name>
            </figure>
         </example>
         <figure id="B3" autonum="3">
            <name id="_">Third</name>
            <fmt-name id="_">
               <span class="fmt-caption-label">
                  <span class="fmt-element-name">Figure</span>
                  <semx element="autonum" source="B3">3</semx>
               </span>
               <span class="fmt-caption-delim">\\u00a0— </span>
               <semx element="name" source="_">Third</semx>
            </fmt-name>
            <fmt-xref-label>
               <span class="fmt-element-name">Figure</span>
               <semx element="autonum" source="B3">3</semx>
            </fmt-xref-label>
         </figure>
      </clause>
    OUTPUT
    expect(strip_guid(Canon.format_xml(Nokogiri::XML(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .at("//xmlns:clause[@id = 'A']").to_xml)))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "label figures embedded within other assets" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
        <preface>
          <foreword id="A">
            <p id="B">
            <table id="C">
            <tbody><td>
            <figure id="D">X</figure>
            </td>
            </tbody>
            </table>
            </p>
       </foreword></preface></standard-document>
    INPUT
    presxml = <<~OUTPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title id="_" depth="1">Table of contents</fmt-title>
              </clause>
              <foreword id="A" displayorder="2">
                 <title id="_">Foreword</title>
                 <fmt-title id="_" depth="1">
                       <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <p id="B">
                    <table id="C" autonum="1">
                       <fmt-name id="_">
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">Table</span>
                             <semx element="autonum" source="C">1</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Table</span>
                          <semx element="autonum" source="C">1</semx>
                       </fmt-xref-label>
                       <tbody>
                          <td>
                             <figure id="D" autonum="1">
                                <fmt-name id="_">
                                   <span class="fmt-caption-label">
                                      <span class="fmt-element-name">Figure</span>
                                      <semx element="autonum" source="D">1</semx>
                                   </span>
                                </fmt-name>
                                <fmt-xref-label>
                                   <span class="fmt-element-name">Figure</span>
                                   <semx element="autonum" source="D">1</semx>
                                </fmt-xref-label>
                                X
                             </figure>
                          </td>
                       </tbody>
                    </table>
                 </p>
              </foreword>
           </preface>
        </standard-document>
    OUTPUT
    expect(strip_guid(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to (presxml)
  end
end
