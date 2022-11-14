require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc do
  it "processes IsoXML metadata #1" do
    c = IsoDoc::Convert.new({})
    c.convert_init(<<~"INPUT", "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
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
        <docidentifier type="ISBN">ISBN 13</docidentifier>
        <docidentifier type="ISBN10">ISBN 10</docidentifier>
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
        <date type="vote-started"><on>2021</on></date>
        <date type="vote-ended"><on>2022</on></date>
        <edition>2</edition><edition language="en">second edition</edition>
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
            <subdivision>Hermeneutics Unit</subdivision>
            <subdivision>Exegesis Subunit</subdivision>
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
        <contributor>
          <role type="author"/>
          <person>
          <name>
            <formatted-initials>B. B.</formatted-initials>
            <surname>Rubble</surname>
            </name>
          </person>
        </contributor>
        <note type="title-footnote"><p>A footnote</p></note>
        <note type="iso"><p>A note</p></note>
        <note type="title-footnote"><p>Another footnote</p></note>
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
        <keyword>KW2</keyword>
        <keyword>KW1</keyword>
        <keyword>KW3</keyword>
        <ext>
        <doctype>international-standard</doctype>
        </ext>
      </bibdata>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      {:accesseddate=>"2012",
      :activateddate=>"2013",
      :agency=>"ISO",
      :authors=>["Barney Rubble", "Fred Flintstone", "B. B. Rubble"],
      :authors_affiliations=>{"Slate Inc., Hermeneutics Unit, Exegesis Subunit, Bedrock"=>["Barney Rubble"], ""=>["Fred Flintstone", "B. B. Rubble"]},
      :circulateddate=>"2015",
      :confirmeddate=>"2017",
      :copieddate=>"2016",
      :createddate=>"2010&#x2013;2011",
      :doc=>"URL E",
      :docnumber=>"17301-1",
      :docnumeric=>"17301",
      :doctitle=>"Cereals and pulses",
      :doctype=>"International Standard",
      :doctype_display=>"International Standard",
      :docyear=>"2016",
      :draft=>"0.4",
      :draftinfo=>" (draft 0.4, 2016-05-01)",
      :edition=>"2",
      :edition_display=>"second edition",
      :html=>"URL B",
      :implementeddate=>"XXX",
      :isbn=>"ISBN 13",
      :isbn10=>"ISBN 10",
      :issueddate=>"XXX",
      :iteration=>"2",
      :keywords=>["KW2", "KW1", "KW3"],
      :lang=>"en",
      :obsoleteddate=>"2014",
      :pdf=>"URL D",
      :publisheddate=>"2011",
      :receiveddate=>"XXX",
      :revdate=>"2016-05-01",
      :revdate_monthyear=>"May 2016",
      :script=>"Latn",
      :stage=>"Committee Draft",
      :stage_display=>"Committee Draft",
      :stageabbr=>"CD",
      :substage=>"Withdrawn",
      :substage_display=>"Withdrawn",
      :title_footnote=>["A footnote", "Another footnote"],
      :transmitteddate=>"2020",
      :unchangeddate=>"2019",
      :unpublished=>true,
      :updateddate=>"2018",
      :url=>"URL A",
      :vote_endeddate=>"2022",
      :vote_starteddate=>"2021",
      :xml=>"URL C"}
    OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end

  it "processes IsoXML metadata #2" do
    c = IsoDoc::Convert.new({})
    c.convert_init(<<~"INPUT", "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
        <title language="fr" format="text/plain">Céréales et légumineuses</ti>
        <title language="en" format="text/plain">Cereals and pulses</title>
        <docidentifier>17301-1-3</docidentifier>
        <docnumber>17301</docnumber>
        <date type="published"><on>2011-01</on></date>
        <version>
        <draft>12</draft>
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
            <subdivision>Subdivision</subdivision>
            <abbreviation>ISO</abbreviation>
            <address>
        <formattedAddress>1 Infinity Loop + California</formattedAddress>
      </address>
      <phone>3333333</phone>
      <phone type='fax'>4444444</phone>
      <email>x@example.com</email>
      <uri>http://www.example.com</uri>
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
      </bibdata>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      {:accesseddate=>"XXX",
      :agency=>"ISO/IEC/IEEE",
      :circulateddate=>"XXX",
      :confirmeddate=>"XXX",
      :copieddate=>"XXX",
      :createddate=>"XXX",
      :docnumber=>"17301-1-3",
      :docnumeric=>"17301",
      :doctitle=>"Cereals and pulses",
      :doctype=>"International Standard",
      :doctype_display=>"International Standard",
      :docyear=>"2016",
      :draft=>"12",
      :draftinfo=>" (draft 12, 2016-05)",
      :implementeddate=>"XXX",
      :issueddate=>"XXX",
      :lang=>"en",
      :obsoleteddate=>"XXX",
      :obsoletes=>"IEC 8121",
      :obsoletes_part=>"3.1",
      :partof=>"IEC 8122",
      :pub_address=>"1 Infinity Loop + California",
      :pub_email=>"x@example.com",
      :pub_fax=>"4444444",
      :pub_phone=>"3333333",
      :pub_uri=>"http://www.example.com",
      :publisheddate=>"2011-01",
      :publisher=>"International Organization for Standardization, International Electrotechnical Commission, and Institute of Electrical and Electronics Engineers",
      :receiveddate=>"XXX",
      :revdate=>"2016-05",
      :revdate_monthyear=>"May 2016",
      :script=>"Latn",
      :stage=>"Published",
      :stage_display=>"Published",
      :subdivision=>"Subdivision",
      :transmitteddate=>"XXX",
      :unchangeddate=>"XXX",
      :unpublished=>false,
      :updateddate=>"XXX",
      :vote_endeddate=>"XXX",
      :vote_starteddate=>"XXX"}
    OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end

  it "processes IsoXML metadata in French" do
    c = IsoDoc::Convert.new({})
    c.convert_init(<<~"INPUT", "test", false)
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
        <language>fr</language>
        <script>Latn</script>
        <status>
          <stage lang="">Committee Draft</stage>
          <stage lang=fr">Projet de comité</stage>
          <substage lang="">Withdrawn</substage>
          <substage lang="fr">Rétiré</substage>
          <iteration>2</iteration>
        </status>
        <edition>2</edition>
      <ext>
      <doctype lang="">international-standard</doctype>
      <doctype lang="fr">Standard international</doctype>
      </ext>
        </bibdata>
        </iso-standard>
    INPUT
    input = <<~INPUT
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
        <status>
          <stage language="">Committee Draft</stage>
          <stage language="fr">Projet de comité</stage>
          <substage language="">Withdrawn</substage>
          <substage language="fr">Rétiré</substage>
          <iteration>2</iteration>
        </status>
        <copyright>
          <from>2016</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
            </organization>
          </owner>
        </copyright>
      <ext>
      <doctype language="">international-standard</doctype>
      <doctype language="fr">Standard international</doctype>
      </ext>
      </bibdata>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      {:accesseddate=>"XXX",
      :agency=>"ISO/IEC",
      :circulateddate=>"XXX",
      :confirmeddate=>"XXX",
      :copieddate=>"XXX",
      :createddate=>"XXX",
      :docnumber=>"17301-1-3",
      :docnumeric=>"17301",
      :doctitle=>"Céréales et légumineuses",
      :doctype=>"International Standard",
      :doctype_display=>"Standard International",
      :docyear=>"2016",
      :implementeddate=>"XXX",
      :issueddate=>"XXX",
      :iteration=>"2",
      :lang=>"fr",
      :obsoleteddate=>"XXX",
      :publisheddate=>"2011-01",
      :publisher=>"International Organization for Standardization et International Electrotechnical Commission",
      :receiveddate=>"XXX",
      :revdate=>"2016-05",
      :revdate_monthyear=>"Mai 2016",
      :script=>"Latn",
      :stage=>"Committee Draft",
      :stage_display=>"Projet De Comité",
      :stageabbr=>"CD",
      :substage=>"Withdrawn",
      :substage_display=>"Rétiré",
      :transmitteddate=>"XXX",
      :unchangeddate=>"XXX",
      :unpublished=>true,
      :updateddate=>"XXX",
      :vote_endeddate=>"XXX",
      :vote_starteddate=>"XXX"}
    OUTPUT
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end
end
