require "spec_helper"

RSpec.describe IsoDoc do
  it "renders form" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
            <clause type="toc" id="_" displayorder="1">
      <title depth="1">Table of contents</title>
    </clause>
      </preface>
          <sections>
          <clause id="A">
          <form action="/action_page.php" id="F0" name="F1" class="C">
        <label for="fname">First name:</label><br/>
        <input type="text" id="fname" name="fname"/><br/>
        <label for="lname">Last name:</label><br/>
        <input type="text" id="lname" name="lname"/><br/>
        <label for="pwd">Password:</label><br/>
        <input type="password" id="pwd" name="pwd"/><br/>
        <input type="radio" id="male" name="gender" value="male"/>
        <label for="male">Male</label><br/>
        <input type="radio" id="female" name="gender" value="female"/>
        <label for="female">Female</label><br/>
        <input type="radio" id="other" name="gender" value="other"/>
        <label for="other">Other</label><br/>
        <input type="checkbox" id="vehicle1" name="vehicle1" value="Bike" checked="true"/>
        <label for="vehicle1"> I have a bike</label><br/>
        <input type="checkbox" id="vehicle2" name="vehicle2" value="Car"/>
        <label for="vehicle2"> I have a car</label><br/>
        <input type="checkbox" id="vehicle3" name="vehicle3" value="Boat"/>
        <label for="vehicle3"> I have a boat</label><br/>
        <input type="date" id="birthday" name="birthday"/><br/>
        <label for="myfile">Select a file:</label>
        <input type="file" id="myfile" name="myfile"/><br/>
        <label for="cars">Select a car:</label>
        <select id="cars" name="cars" value="fiat">
        <option value="volvo">Volvo</option>
        <option value="saab">Saab</option>
        <option value="fiat">Fiat</option>
        <option value="audi">Audi</option>
        </select>
        <textarea id="t1" name="message" rows="10" cols="30" value="The cat was playing in the garden."/>
        <input type="button" value="Click Me!"/>
        <input type="button"/>
        <input type="submit" value="Submit"/>
      </form>
          </clause>
      </sections>
      </iso-standard>
    INPUT

    html = <<~HTML
      #{HTML_HDR}
                  <p class='zzSTDTitle1'/>
               <div id='A'>
                 <h1/>
               <form id='F0' name='F1' action='/action_page.php' class="C">
                  <label for='fname'>First name:</label>
                   <br/>
                   <input id='fname' name='fname' type='text'/>
                   <br/>
                   <label for='lname'>Last name:</label>
                   <br/>
                   <input id='lname' name='lname' type='text'/>
                   <br/>
                   <label for='pwd'>Password:</label>
                   <br/>
                   <input id='pwd' name='pwd' type='password'/>
                   <br/>
                   <input id='male' name='gender' type='radio' value='male'/>
                   <label for='male'>Male</label>
                   <br/>
                   <input id='female' name='gender' type='radio' value='female'/>
                   <label for='female'>Female</label>
                   <br/>
                   <input id='other' name='gender' type='radio' value='other'/>
                   <label for='other'>Other</label>
                   <br/>
                   <input id='vehicle1' name='vehicle1' type='checkbox' value='Bike' checked='true'/>
                   <label for='vehicle1'> I have a bike</label>
                   <br/>
                   <input id='vehicle2' name='vehicle2' type='checkbox' value='Car'/>
                   <label for='vehicle2'> I have a car</label>
                   <br/>
                   <input id='vehicle3' name='vehicle3' type='checkbox' value='Boat'/>
                   <label for='vehicle3'> I have a boat</label>
                   <br/>
                   <input id='birthday' name='birthday' type='date'/>
                   <br/>
                   <label for='myfile'>Select a file:</label>
                   <input id='myfile' name='myfile' type='file'/>
                   <br/>
                   <label for='cars'>Select a car:</label>
                   <select id='cars' name='cars'>
                     <option value='volvo'>Volvo</option>
                     <option value='saab'>Saab</option>
                     <option selected='true' value='fiat'>Fiat</option>
                     <option value='audi'>Audi</option>
                   </select>
                   <textarea id='t1' name='message' rows='10' cols='30'>The cat was playing in the garden.</textarea>
                   <input type='button' value='Click Me!'/>
                   <input type='button'/>
                   <input type='submit' value='Submit'/>
                  </form>
               </div>
             </div>
           </body>
         </html>
    HTML

    doc = <<~DOC
      #{WORD_HDR}
                  <p class='zzSTDTitle1'/>
               <div id='A'>
                 <h1/>
                 <div class="C" id="F0">
                  First name:
                 <br/>
                  __________
                 <br/>
                  Last name:
                 <br/>
                  __________
                 <br/>
                  Password:
                 <br/>
                  __________
                 <br/>
                  &#9678; Male
                 <br/>
                  &#9678; Female
                 <br/>
                  &#9678; Other
                 <br/>
                  &#9744; I have a bike
                 <br/>
                  &#9744; I have a car
                 <br/>
                  &#9744; I have a boat
                 <br/>
                  __________
                 <br/>
                  Select a file: __________
                 <br/>
                  Select a car: __________
                 <table border='1' width='50%'>
                   <tr>
                     <td/>
                   </tr>
                 </table>
                  [Click Me!] [BUTTON]
                  </div>
               </div>
             </div>
           </body>
         </html>
    DOC

    expect(xmlpp(IsoDoc::HtmlConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(html)
    expect(xmlpp(IsoDoc::WordConvert.new({})
      .convert("test", input, true))).to be_equivalent_to xmlpp(doc)
  end
end
