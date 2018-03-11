require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc do
  it "cleans up admonitions" do
    expect(IsoDoc::Convert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
    <html>
    <body>
      <div class="Admonition">
        <title>Warning</title>
        <p>Text</p>
      </div>
    </body>
    </html>
    INPUT
           <?xml version="1.0"?>
       <html>
       <body>
         <div class="Admonition">

           <p>Warning&#x2014;Text</p>
         </div>
       </body>
       </html>
    OUTPUT
  end
end
