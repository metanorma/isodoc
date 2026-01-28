require "spec_helper"

RSpec.describe IsoDoc do
  it "manipulates identifier attributes in Presentation XML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
          <clause id="A"/>
          <clause id="B" anchor="C"/>
          <clause id="D" anchor="Löwe">
            <xref target="Löwe"/>
          </clause>
        </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <preface>
             <clause type="toc" id="_" displayorder="1">
                <fmt-title id="_" depth="1">Table of contents</fmt-title>
             </clause>
          </preface>
          <sections>
             <clause id="A" semx-id="A" displayorder="2">
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="A">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="A">1</semx>
                </fmt-xref-label>
             </clause>
             <clause id="C" anchor="C" semx-id="B" displayorder="3">
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="C">2</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="C">2</semx>
                </fmt-xref-label>
             </clause>
             <clause id="Löwe" anchor="Löwe" semx-id="D" displayorder="4">
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="Löwe">3</semx>
                      <span class="fmt-autonum-delim">.</span>
                   </span>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="Löwe">3</semx>
                </fmt-xref-label>
                <xref target="Löwe" id="_"/>
                <semx element="xref" source="_">
                   <fmt-xref target="Löwe">
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="Löwe">3</semx>
                   </fmt-xref>
                </semx>
             </clause>
          </sections>
       </iso-standard>
    OUTPUT
    expect(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r("_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), '"_"'))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "uses content GUIDs in Presentation XML" do
    input = <<~INPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
            <bibdata/>
      <preface>
      <floating-title>FL 7</p>
      <executivesummary/>
      <floating-title>FL 0</p>
      <acknowledgements/>
      <floating-title>FL 1</p>
      <floating-title>FL 2</p>
      <introduction/>
      <floating-title>FL 3</p>
      <floating-title>FL 4</p>
      <foreword><title>Foreword 1</title></foreword>
      <floating-title>FL 5</p>
      <foreword><title>Foreword 2</title></foreword>
      <floating-title>FL 6</p>
      <abstract/>
      </preface>
      </standard-document>
    INPUT
    presxml = <<~OUTPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
         <bibdata/>
         <preface>
            <clause type="toc" id="_ad031967-2ffb-7abe-7724-fe42e3e69ab6" displayorder="1">
               <fmt-title depth="1" id="_94e961da-c46e-10c4-3633-df05fa9b249b">Table of contents</fmt-title>
            </clause>
            <floating-title original-id="_7a358acc-ba01-efef-79d3-ffddb271a5f2">FL 6</floating-title>
            <p id="_6bc6edd4-ce02-3d09-6fb9-fe9a58b0add6" type="floating-title" displayorder="2">
               <semx element="floating-title" source="_6bc6edd4-ce02-3d09-6fb9-fe9a58b0add6">FL 6</semx>
            </p>
            <abstract id="_342ec181-36d5-e26a-f135-7a2ab9504cc7" displayorder="3"/>
            <floating-title original-id="_5eb946b0-308e-6eba-08b6-6b4c87e08eed">FL 3</floating-title>
            <p id="_b702b5ff-2973-3b1f-b5a1-ef974f0dcb53" type="floating-title" displayorder="4">
               <semx element="floating-title" source="_b702b5ff-2973-3b1f-b5a1-ef974f0dcb53">FL 3</semx>
            </p>
            <floating-title original-id="_9e7ab2e8-e33c-91c3-7744-66800e5b8a87">FL 4</floating-title>
            <p id="_2eb9f685-30aa-f993-e7ce-77a904a5998c" type="floating-title" displayorder="5">
               <semx element="floating-title" source="_2eb9f685-30aa-f993-e7ce-77a904a5998c">FL 4</semx>
            </p>
            <foreword id="_92a0fd29-1e23-10a1-7ccf-79659e1d55c4" displayorder="6">
               <title id="_6ef51b59-4654-aa9d-dd44-776977643101">Foreword 1</title>
               <fmt-title depth="1" id="_78ad0ed3-d83f-8139-0bcd-200a2d61daf5">
                  <semx element="title" source="_6ef51b59-4654-aa9d-dd44-776977643101">Foreword 1</semx>
               </fmt-title>
            </foreword>
            <floating-title original-id="_e448c5b5-a5e2-25ba-292b-bc6388f9c0bb">FL 5</floating-title>
            <p id="_d01a6376-a126-1b02-481e-e66a095e91fd" type="floating-title" displayorder="7">
               <semx element="floating-title" source="_d01a6376-a126-1b02-481e-e66a095e91fd">FL 5</semx>
            </p>
            <foreword id="_35070999-7e5f-7e8f-cf70-1ca23584af50" displayorder="8">
               <title id="_bb6f6961-5f5e-540e-e2a9-bfd743bea25f">Foreword 2</title>
               <fmt-title depth="1" id="_d7ffd817-6fae-c526-d5cb-5b33e3f75cea">
                  <semx element="title" source="_bb6f6961-5f5e-540e-e2a9-bfd743bea25f">Foreword 2</semx>
               </fmt-title>
            </foreword>
            <floating-title original-id="_6d170179-ba49-4af9-ed38-7987c1a7cbe0">FL 1</floating-title>
            <p id="_f8a8f840-3950-a27d-a79d-7db536f9980a" type="floating-title" displayorder="9">
               <semx element="floating-title" source="_f8a8f840-3950-a27d-a79d-7db536f9980a">FL 1</semx>
            </p>
            <floating-title original-id="_a139118f-038f-e387-88cc-9dbf651bcbcb">FL 2</floating-title>
            <p id="_9fdb84cf-58b7-1ac8-450f-29cfe0117412" type="floating-title" displayorder="10">
               <semx element="floating-title" source="_9fdb84cf-58b7-1ac8-450f-29cfe0117412">FL 2</semx>
            </p>
            <introduction id="_27e1812e-2d86-ea96-5220-c895b505e1aa" displayorder="11"/>
            <floating-title original-id="_6cfccd90-6101-23b5-f708-728b534920f9">FL 0</floating-title>
            <p id="_2b26a4c5-3893-fdd2-ab37-0be1cf6424d4" type="floating-title" displayorder="12">
               <semx element="floating-title" source="_2b26a4c5-3893-fdd2-ab37-0be1cf6424d4">FL 0</semx>
            </p>
            <acknowledgements id="_8afab461-7af9-b53a-d387-6ff08ef0e2d1" displayorder="13"/>
            <floating-title original-id="_5622af3a-8c11-41a3-2998-1f268a74ac1c">FL 7</floating-title>
            <p id="_c888c2f8-b742-0209-ffaa-d5783dec2c65" type="floating-title" displayorder="14">
               <semx element="floating-title" source="_c888c2f8-b742-0209-ffaa-d5783dec2c65">FL 7</semx>
            </p>
            <executivesummary id="_3d8ba6d3-5e1a-e024-7985-661f63bdab97" displayorder="15"/>
         </preface>
      </standard-document>
    OUTPUT
    expect(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(presxml)
    presxml = <<~OUTPUT
      <standard-document xmlns="https://www.metanorma.org/ns/standoc" document_suffix="doc001" type="presentation">
         <bibdata/>
         <preface>
            <clause type="toc" id="_ad031967-2ffb-7abe-7724-fe42e3e69ab6_doc001" displayorder="1">
               <fmt-title depth="1" id="_94e961da-c46e-10c4-3633-df05fa9b249b_doc001">Table of contents</fmt-title>
            </clause>
            <floating-title original-id="_7a358acc-ba01-efef-79d3-ffddb271a5f2_doc001">FL 6</floating-title>
            <p id="_6bc6edd4-ce02-3d09-6fb9-fe9a58b0add6_doc001" type="floating-title" displayorder="2">
               <semx element="floating-title" source="_6bc6edd4-ce02-3d09-6fb9-fe9a58b0add6_doc001">FL 6</semx>
            </p>
            <abstract id="_342ec181-36d5-e26a-f135-7a2ab9504cc7_doc001" displayorder="3"/>
            <floating-title original-id="_5eb946b0-308e-6eba-08b6-6b4c87e08eed_doc001">FL 3</floating-title>
            <p id="_b702b5ff-2973-3b1f-b5a1-ef974f0dcb53_doc001" type="floating-title" displayorder="4">
               <semx element="floating-title" source="_b702b5ff-2973-3b1f-b5a1-ef974f0dcb53_doc001">FL 3</semx>
            </p>
            <floating-title original-id="_9e7ab2e8-e33c-91c3-7744-66800e5b8a87_doc001">FL 4</floating-title>
            <p id="_2eb9f685-30aa-f993-e7ce-77a904a5998c_doc001" type="floating-title" displayorder="5">
               <semx element="floating-title" source="_2eb9f685-30aa-f993-e7ce-77a904a5998c_doc001">FL 4</semx>
            </p>
            <foreword id="_92a0fd29-1e23-10a1-7ccf-79659e1d55c4_doc001" displayorder="6">
               <title id="_6ef51b59-4654-aa9d-dd44-776977643101_doc001">Foreword 1</title>
               <fmt-title depth="1" id="_78ad0ed3-d83f-8139-0bcd-200a2d61daf5_doc001">
                  <semx element="title" source="_6ef51b59-4654-aa9d-dd44-776977643101_doc001">Foreword 1</semx>
               </fmt-title>
            </foreword>
            <floating-title original-id="_e448c5b5-a5e2-25ba-292b-bc6388f9c0bb_doc001">FL 5</floating-title>
            <p id="_d01a6376-a126-1b02-481e-e66a095e91fd_doc001" type="floating-title" displayorder="7">
               <semx element="floating-title" source="_d01a6376-a126-1b02-481e-e66a095e91fd_doc001">FL 5</semx>
            </p>
            <foreword id="_35070999-7e5f-7e8f-cf70-1ca23584af50_doc001" displayorder="8">
               <title id="_bb6f6961-5f5e-540e-e2a9-bfd743bea25f_doc001">Foreword 2</title>
               <fmt-title depth="1" id="_d7ffd817-6fae-c526-d5cb-5b33e3f75cea_doc001">
                  <semx element="title" source="_bb6f6961-5f5e-540e-e2a9-bfd743bea25f_doc001">Foreword 2</semx>
               </fmt-title>
            </foreword>
            <floating-title original-id="_6d170179-ba49-4af9-ed38-7987c1a7cbe0_doc001">FL 1</floating-title>
            <p id="_f8a8f840-3950-a27d-a79d-7db536f9980a_doc001" type="floating-title" displayorder="9">
               <semx element="floating-title" source="_f8a8f840-3950-a27d-a79d-7db536f9980a_doc001">FL 1</semx>
            </p>
            <floating-title original-id="_a139118f-038f-e387-88cc-9dbf651bcbcb_doc001">FL 2</floating-title>
            <p id="_9fdb84cf-58b7-1ac8-450f-29cfe0117412_doc001" type="floating-title" displayorder="10">
               <semx element="floating-title" source="_9fdb84cf-58b7-1ac8-450f-29cfe0117412_doc001">FL 2</semx>
            </p>
            <introduction id="_27e1812e-2d86-ea96-5220-c895b505e1aa_doc001" displayorder="11"/>
            <floating-title original-id="_6cfccd90-6101-23b5-f708-728b534920f9_doc001">FL 0</floating-title>
            <p id="_2b26a4c5-3893-fdd2-ab37-0be1cf6424d4_doc001" type="floating-title" displayorder="12">
               <semx element="floating-title" source="_2b26a4c5-3893-fdd2-ab37-0be1cf6424d4_doc001">FL 0</semx>
            </p>
            <acknowledgements id="_8afab461-7af9-b53a-d387-6ff08ef0e2d1_doc001" displayorder="13"/>
            <floating-title original-id="_5622af3a-8c11-41a3-2998-1f268a74ac1c_doc001">FL 7</floating-title>
            <p id="_c888c2f8-b742-0209-ffaa-d5783dec2c65_doc001" type="floating-title" displayorder="14">
               <semx element="floating-title" source="_c888c2f8-b742-0209-ffaa-d5783dec2c65_doc001">FL 7</semx>
            </p>
            <executivesummary id="_3d8ba6d3-5e1a-e024-7985-661f63bdab97_doc001" displayorder="15"/>
         </preface>
      </standard-document>
    OUTPUT
    expect(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input.sub("<standard-document ",
                                 "<standard-document document_suffix='doc001' "), true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "validates on duplicate identifiers" do
    FileUtils.rm_f "test.presentation.xml"
    log = Metanorma::Utils::Log.new
    IsoDoc::PresentationXMLConvert.new({ filename: "test", log: log }
      .merge(presxml_options))
      .convert("test", <<~INPUT, false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
    expect(log.abort_messages).to be_empty
    log = Metanorma::Utils::Log.new
    IsoDoc::PresentationXMLConvert.new({ filename: "test", log: log }
      .merge(presxml_options))
      .convert("test", <<~INPUT, false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
    expect(log.abort_messages).not_to be_empty
    expect(log.abort_messages.first).to eq "ID _f06fd0d1-a203-4f3d-a515-0bdba0f8d83e has already been used at line 7"
  end

  it "validates on undefined IDREF" do
    FileUtils.rm_f "test.presentation.xml"
    FileUtils.rm_f "test.html.err"
    log = Metanorma::Utils::Log.new
    IsoDoc::PresentationXMLConvert.new({ filename: "test", log: log }
      .merge(presxml_options))
      .convert("test", <<~INPUT, false)
                <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
            <title id="A">Hello</title>
            <fmt-title source="A">Hello</fmt-title>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
    expect(log.abort_messages).to be_empty
    log.write("test.err.html")
    html = File.read("test.err.html")
    expect(html).not_to include "is not defined in the document"

    log = Metanorma::Utils::Log.new
    FileUtils.rm_f "test.presentation.xml"
    FileUtils.rm_f "test.html.err"
    IsoDoc::PresentationXMLConvert.new({ filename: "test", log: log }
      .merge(presxml_options))
      .convert("test", <<~INPUT, false)
                    <iso-standard xmlns="http://riboseinc.com/isoxml">
                <bibdata>
                <title language="en">test</title>
                </bibdata>
            <preface><foreword>
            <note>
            <title id="A">Hello</title>
            <fmt-title source="B">Hello</fmt-title>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
    INPUT
    expect(File.exist?("test.presentation.xml")).to be true
    expect(log.abort_messages).to be_empty
    log.write("test.err.html")
    html = File.read("test.err.html")
    expect(html).to include "Anchor B pointed to by fmt-title is not defined in the document"
  end

  it "processes duplicate ids between Semantic and Presentation XML titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
           <sections>
           <clause id="A1">
           <title>Title <bookmark id="A2"/> <index><primary>title</primary></index></title>
           </clause>
           </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
         <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
             <preface>
                <clause type="toc" id="_" displayorder="1">
                   <fmt-title id="_" depth="1">Table of contents</fmt-title>
                </clause>
             </preface>
             <sections>
                <clause id="A1" displayorder="2">
                   <title id="_">
                      Title
                      <bookmark original-id="A2"/>
                   </title>
                   <fmt-title id="_" depth="1">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="A1">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">
                         Title
                         <bookmark id="A2"/>
                         <bookmark id="_"/>
                      </semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Clause</span>
                      <semx element="autonum" source="A1">1</semx>
                   </fmt-xref-label>
                </clause>
             </sections>
                   <indexsect id="_" displayorder="3">
         <fmt-title id="_">Index</fmt-title>
         <ul>
            <li id="_">
               <fmt-name id="_">
                  <semx element="autonum" source="_">—</semx>
               </fmt-name>
               title,
               <xref target="_" pagenumber="true" id="_"/>
               <semx element="xref" source="_">
                  <fmt-xref target="_" pagenumber="true">
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="A1">1</semx>
                  </fmt-xref>
               </semx>
            </li>
         </ul>
      </indexsect>
          </iso-standard>
    OUTPUT
    expect(strip_guid(Canon.format_xml(IsoDoc::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
