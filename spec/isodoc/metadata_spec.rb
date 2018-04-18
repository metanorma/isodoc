require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc do
  it "processes IsoXML metadata" do
    expect(Hash[IsoDoc::Convert.new({}).info(Nokogiri::XML(<<~"INPUT"), nil).sort]).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="international-standard">
  <title>
    <title-intro language="en" format="text/plain">Cereals and pulses</title-intro>
    <title-main language="en" format="text/plain">Specifications and test methods</title-main>
    <title-part language="en" format="text/plain">Rice</title-part>
  </title>
  <title>
    <title-intro language="fr" format="text/plain">Céréales et légumineuses</title-intro>
    <title-main language="fr" format="text/plain">Spécification et méthodes d'essai</title-main>
    <title-part language="fr" format="text/plain">Riz</title-part>
  </title>
  <docidentifier>
    <project-number part="1">17301</project-number>
    <tc-document-number>17301</tc-document-number>
  </docidentifier>
  <date type="published"><from>2011</from></date>
  <date type="accessed"><from>2012</from></date>
  <date type="created"><from>2010</from><to>2011</to></date>
  <date type="activated"><from>2013</from></date>
  <date type="obsoleted"><from>2014</from></date>
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
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>30</stage>
    <substage>92</substage>
    <iteration>3</iteration>
  </status>
  <copyright>
    <from>2016</from>
    <owner>
      <organization>
        <abbreviation>ISO</abbreviation>
      </organization>
    </owner>
  </copyright>
  <editorialgroup>
    <technical-committee number="34">Food products</technical-committee>
    <subcommittee number="4">Cereals and pulses</subcommittee>
    <workgroup number="3">Rice Group</workgroup>
    <secretariat>GB</secretariat>
  </editorialgroup>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2016-05-01</revision-date>
  <draft>0.4</draft>
</version>
</iso-standard>
INPUT
       {:accesseddate=>"2012", :activateddate=>"2013", :agency=>"ISO", :confirmeddate=>"XXX", :createddate=>"2010&ndash;2011", :docnumber=>"PreCD3 17301-1", :docsubtitle=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses&nbsp;&mdash; Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai&nbsp;&mdash; Partie&nbsp;1: Riz", :doctitle=>"Cereals and pulses&nbsp;&mdash; Specifications and test methods&nbsp;&mdash; Part&nbsp;1: Rice", :doctype=>"International Standard", :docyear=>"2016", :draft=>"0.4", :draftinfo=>" ( 0.4, 2016-05-01)", :editorialgroup=>["TC 34", "SC 4", "WG 3"], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"2014", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"2011", :revdate=>"2016-05-01", :sc=>"SC 4", :secretariat=>"GB", :stage=>"30", :stageabbr=>"PreCD3", :tc=>"TC 34", :updateddate=>"XXX", :wg=>"WG 3"}
OUTPUT
  end

  it "processes IsoXML metadata" do
    expect(Hash[IsoDoc::Convert.new({}).info(Nokogiri::XML(<<~"INPUT"), nil).sort]).to be_equivalent_to <<~"OUTPUT"
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata type="international-standard">
  <title>
    <title-intro language="en" format="text/plain">Cereals and pulses</title-intro>
    <title-main language="en" format="text/plain">Specifications and test methods</title-main>
    <title-part language="en" format="text/plain">Rice</title-part>
  </title>
  <title>
    <title-intro language="fr" format="text/plain">Céréales et légumineuses</title-intro>
    <title-main language="fr" format="text/plain">Spécification et méthodes d'essai</title-main>
    <title-part language="fr" format="text/plain">Riz</title-part>
  </title>
  <docidentifier>
    <project-number part="1" subpart="3">17301</project-number>
    <tc-document-number>17301</tc-document-number>
  </docidentifier>
  <contributor>
    <role type="author"/>
    <organization>
      <name>ISO</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISO</abbreviation>
     </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>IEC</abbreviation>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage>30</stage>
    <substage>92</substage>
  </status>
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
  <editorialgroup>
    <technical-committee number="34" type="ABC">Food products</technical-committee>
    <subcommittee number="4" type="DEF">Cereals and pulses</subcommittee>
    <workgroup number="3" type="GHI">Rice Group</workgroup>
  </editorialgroup>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2016-05-01</revision-date>
  <draft>12</draft>
</version>
</iso-standard>
INPUT
{:accesseddate=>"XXX", :agency=>"ISO/IEC", :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"CD 17301-1-3", :docsubtitle=>"C&#xe9;r&#xe9;ales et l&#xe9;gumineuses&nbsp;&mdash; Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai&nbsp;&mdash; Partie&nbsp;1&ndash;3: Riz", :doctitle=>"Cereals and pulses&nbsp;&mdash; Specifications and test methods&nbsp;&mdash; Part&nbsp;1&ndash;3: Rice", :doctype=>"International Standard", :docyear=>"2016", :draft=>"12", :draftinfo=>" ( 12, 2016-05-01)", :editorialgroup=>["ABC 34", "DEF 4", "GHI 3"], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>"IEC 8121", :obsoletes_part=>"3.1", :publisheddate=>"XXX", :revdate=>"2016-05-01", :sc=>"DEF 4", :secretariat=>"XXXX", :stage=>"30", :stageabbr=>"CD", :tc=>"ABC 34", :updateddate=>"XXX", :wg=>"GHI 3"}
OUTPUT
  end

end
