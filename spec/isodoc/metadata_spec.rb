require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc do
  it "processes IsoXML metadata" do
    c = IsoDoc::Convert.new({})
    arr = c.convert_init(<<~"INPUT", "test", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
  expect(Hash[c.info(Nokogiri::XML(<<~"INPUT"), nil).sort]).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="standard">
  <title>The Incredible Mr Ripley</title>
  <title language="en">Cereals and pulses</title>
  <uri>URL A</uri>
  <uri type="html">URL B</uri>
  <uri type="xml">URL C</uri>
  <uri type="pdf">URL D</uri>
  <uri type="doc">URL E</uri>
  <docidentifier>17301-1</docidentifier>
  <docnumber>17301</docnumber>
  <date type="published"><on>2011</on></date>
  <date type="accessed"><on>2012</on></date>
  <date type="created"><from>2010</from><to>2011</to></date>
  <date type="activated"><on>2013</on></date>
  <date type="obsoleted"><on>2014</on></date>
  <date type="circulated"><on>2015</on></date>
  <date type="copied"><on>2016</on></date>
  <date type="confirmed"><on>2017</on></date>
  <date type="updated"><on>2018</on></date>
  <date type="unchanged"><on>2019</on></date>
  <date type="transmitted"><on>2020</on></date>
  <edition>2</edition>
<version>
  <revision-date>2016-05-01</revision-date>
  <draft>0.4</draft>
</version>
  <contributor>
    <role type="author"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
    <contributor>
    <role type="editor"/>
    <person>
    <name>
    <forename>Barney</forename>
      <surname>Rubble</surname>
      </name>
      <affiliation>
      <organization><name>Slate Inc.</name>
      <address>
      <formattedAddress>Bedrock</formattedAddress>
      </address>
        </organization>
      </affiliation>
    </person>
  </contributor>
  <contributor>
    <role type="author"/>
    <person>
    <name>
      <completename>Fred Flintstone</completename>
      </name>
    </person>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>Committee Draft</stage>
    <substage>Withdrawn</substage>
    <iteration>2</iteration>
  </status>
  <copyright>
    <from>2016</from>
    <owner>
      <organization>
        <abbreviation>ISO</abbreviation>
      </organization>
    </owner>
  </copyright>
  <ext>
  <doctype>international-standard</doctype>
  </ext>
</bibdata>
</iso-standard>
INPUT
{:accesseddate=>"2012", :activateddate=>"2013", :agency=>"ISO", :authors=>["Barney Rubble", "Fred Flintstone"], :authors_affiliations=>{"Slate Inc., Bedrock"=>["Barney Rubble"], ""=>["Fred Flintstone"]}, :circulateddate=>"2015", :confirmeddate=>"2017", :copieddate=>"2016", :createddate=>"2010&ndash;2011", :doc=>"URL E", :docnumber=>"17301-1", :docnumeric=>"17301", :doctitle=>"Cereals and pulses", :doctype=>"International Standard", :docyear=>"2016", :draft=>"0.4", :draftinfo=>" (draft 0.4, 2016-05-01)", :edition=>"2", :html=>"URL B", :implementeddate=>"XXX", :issueddate=>"XXX", :iteration=>"2", :obsoleteddate=>"2014", :pdf=>"URL D", :publisheddate=>"2011", :publisher=>"", :receiveddate=>"XXX", :revdate=>"2016-05-01", :revdate_monthyear=>"May 2016", :stage=>"Committee draft", :stageabbr=>"CD", :substage=>"Withdrawn", :transmitteddate=>"2020", :unchangeddate=>"2019", :unpublished=>true, :updateddate=>"2018", :url=>"URL A", :xml=>"URL C"}
OUTPUT
  end

  it "processes IsoXML metadata" do
        c = IsoDoc::Convert.new({})
    arr = c.convert_init(<<~"INPUT", "test", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
  expect(Hash[c.info(Nokogiri::XML(<<~"INPUT"), nil).sort]).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="standard">
  <title language="fr" format="text/plain">Céréales et légumineuses</ti>
  <title language="en" format="text/plain">Cereals and pulses</title>
  <docidentifier>17301-1-3</docidentifier>
  <docnumber>17301</docnumber>
  <date type="published"><on>2011-01</on></date>
  <version>
  <revision-date>2016-05</revision-date>
</version>
  <contributor>
    <role type="author"/>
    <organization>
      <name>ISO</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
      <abbreviation>ISO</abbreviation>
     </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Electrotechnical Commission</name>
      <abbreviation>IEC</abbreviation>
    </organization>
  </contributor>
   <contributor>
    <role type="publisher"/>
    <organization>
      <name>Institute of Electrical and Electronics Engineers</name>
      <abbreviation>IEEE</abbreviation>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status><stage>Published</stage></status>
  <copyright>
    <from>2016</from>
    <owner>
      <organization>
        <name>International Organization for Standardization</name>
      </organization>
    </owner>
  </copyright>
  <relation type="obsoletes">
    <locality type="clause"><referenceFrom>3.1</referenceFrom></locality>
    <docidentifier>IEC 8121</docidentifier>
  </relation>
  <relation type="partOf">
    <docidentifier>IEC 8122</docidentifier>
  </relation>
  <ext>
  <doctype>international-standard</doctype>
  </ext>
</bibdata><version>
  <revision-date>2016-05-01</revision-date>
  <draft>12</draft>
</version>
</iso-standard>
INPUT
{:accesseddate=>"XXX", :agency=>"ISO/IEC/IEEE", :authors=>[], :authors_affiliations=>{}, :circulateddate=>"XXX", :confirmeddate=>"XXX", :copieddate=>"XXX", :createddate=>"XXX", :docnumber=>"17301-1-3", :docnumeric=>"17301", :doctitle=>"Cereals and pulses", :doctype=>"International Standard", :docyear=>"2016", :draft=>"12", :draftinfo=>" (draft 12, 2016-05)", :edition=>nil, :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>"IEC 8121", :obsoletes_part=>"3.1", :partof=>"IEC 8122", :publisheddate=>"2011-01", :publisher=>"International Organization for Standardization, International Electrotechnical Commission and Institute of Electrical and Electronics Engineers", :receiveddate=>"XXX", :revdate=>"2016-05", :revdate_monthyear=>"May 2016", :stage=>"Published", :transmitteddate=>"XXX", :unchangeddate=>"XXX", :unpublished=>false, :updateddate=>"XXX"}
OUTPUT
  end

    it "processes IsoXML metadata in French" do
        c = IsoDoc::Convert.new({})
    arr = c.convert_init(<<~"INPUT", "test", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="standard">
  <language>fr</language>
  <script>Latn</script>
  </bibdata>
  </iso-standard>
    INPUT
  expect(Hash[c.info(Nokogiri::XML(<<~"INPUT"), nil).sort]).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="standard">
  <title language="fr" format="text/plain">Céréales et légumineuses</ti>
  <title language="en" format="text/plain">Cereals and pulses</title>
  <docidentifier>17301-1-3</docidentifier>
  <docnumber>17301</docnumber>
  <date type="published"><on>2011-01</on></date>
  <version>
  <revision-date>2016-05</revision-date>
</version>
  <contributor>
    <role type="author"/>
    <organization>
      <name>ISO</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
      <abbreviation>ISO</abbreviation>
     </organization>
  </contributor>
   <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Electrotechnical Commission</name>
      <abbreviation>IEC</abbreviation>
    </organization>
  </contributor>
  <language>fr</language>
  <script>Latn</script>
  <status><stage>Published</stage></status>
  <copyright>
    <from>2016</from>
    <owner>
      <organization>
        <name>International Organization for Standardization</name>
      </organization>
    </owner>
  </copyright>
</bibdata>
</iso-standard>
INPUT
{:accesseddate=>"XXX", :agency=>"ISO/IEC", :authors=>[], :authors_affiliations=>{}, :circulateddate=>"XXX", :confirmeddate=>"XXX", :copieddate=>"XXX", :createddate=>"XXX", :docnumber=>"17301-1-3", :docnumeric=>"17301", :doctitle=>"Cereals and pulses", :docyear=>"2016", :draft=>nil, :draftinfo=>"", :edition=>nil, :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :publisheddate=>"2011-01", :publisher=>"International Organization for Standardization et International Electrotechnical Commission", :receiveddate=>"XXX", :revdate=>"2016-05", :revdate_monthyear=>"Mai 2016", :stage=>"Published", :transmitteddate=>"XXX", :unchangeddate=>"XXX", :unpublished=>false, :updateddate=>"XXX"}
OUTPUT
end


end
