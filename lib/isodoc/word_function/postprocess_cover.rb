module IsoDoc
  module WordFunction
    module Postprocess
      def word_preface(docxml)
        @wordcoverpage && !@wordcoverpage.empty? and
          word_cover(docxml)
        @wordintropage && !@wordintropage.empty? and
          word_intro(docxml, @wordToClevels)
      end

      def word_remove_empty_sections(docxml)
        %w(WordSection1 WordSection2).each do |x|
          ins = docxml.at("//div[@class='#{x}']") or next
          @c.decode(ins.text).gsub(/\p{Z}|\p{C}/, "").strip.empty? or next
          ins.next_element.remove
          ins.remove
        end
      end

      def word_cover(docxml)
        ins = docxml.at('//div[@class="WordSection1"]') or return
        cover = File.read(@wordcoverpage, encoding: "UTF-8")
        cover = populate_template(cover, :word)
        coverxml = to_word_xhtml_fragment(cover)
        ins.add_first_child coverxml.to_xml(encoding: "US-ASCII")
      end

      def word_intro(docxml, level)
        ins = docxml.at('//div[@class="WordSection2"]') or return
        intro = insert_toc(File.read(@wordintropage, encoding: "UTF-8"),
                           docxml, level)
        intro = populate_template(intro, :word)
        introxml = to_word_xhtml_fragment(intro)
        ins.add_first_child introxml.to_xml(encoding: "US-ASCII")
      end

      # add namespaces for Word fragments
      WORD_NOKOHEAD = <<~HERE.freeze
        <!DOCTYPE html SYSTEM "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml"
        xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"
        xmlns:w="urn:schemas-microsoft-com:office:word"
        xmlns:m="http://schemas.microsoft.com/office/2004/12/omml">
        <head> <title></title> <meta charset="UTF-8" /> </head>
        <body> </body> </html>
      HERE

      def to_word_xhtml_fragment(xml)
        doc = ::Nokogiri::XML.parse(WORD_NOKOHEAD)
        ::Nokogiri::XML::DocumentFragment.new(doc, xml, doc.root)
      end

      def wordstylesheet_update
        @wordstylesheet.nil? and return
        f = File.open(@wordstylesheet.path, "a")
        @landscapestyle.empty? or f.write(@landscapestyle)
        s = @meta.get[:code_css] and
          f.write(s.gsub(/sourcecode/, "p.#{sourcecode_style}"))
        if @wordstylesheet_override && @wordstylesheet
          f.write(@wordstylesheet_override.read)
          @wordstylesheet_override.close
        elsif @wordstylesheet_override && !@wordstylesheet
          @wordstylesheet = @wordstylesheet_override
        end
        f.close
        @wordstylesheet
      end

      def authority_cleanup1(docxml, klass)
        dest = docxml.at("//div[@id = 'boilerplate-#{klass}-destination']")
        auth = docxml.at("//div[@id = 'boilerplate-#{klass}' " \
                         "or @class = 'boilerplate-#{klass}']")
        auth&.xpath(".//h1[not(text())] | .//h2[not(text())]")&.each(&:remove)
        auth&.xpath(".//h1 | .//h2")&.each do |h|
          h.name = "p"
          h["class"] = "TitlePageSubhead"
        end
        dest and auth and dest.replace(auth.remove)
      end

      def authority_cleanup(docxml)
        %w(copyright license legal feedback).each do |t|
          authority_cleanup1(docxml, t)
        end
        coverpage_note_cleanup(docxml)
      end

      def coverpage_note_cleanup(docxml)
        if dest = docxml.at("//div[@id = 'coverpage-note-destination']")
          auth = docxml.xpath("//*[@coverpage]")
          if auth.empty? then dest.remove
          else
            auth.each do |x|
              dest << x.remove
            end
          end
        end
        docxml.xpath("//*[@coverpage]").each { |x| x.delete("coverpage") }
      end

      def generate_header(filename, _dir)
        @header or return nil
        template = IsoDoc::Common.liquid(File.read(@header, encoding: "UTF-8"))
        params = header_params(filename)
        Tempfile.open(%w(header html),
                      mode: File::BINARY | File::SHARE_DELETE,
                      encoding: "utf-8") do |f|
          f.write(template.render(params))
          f
        end
      end

      def header_params(filename)
        meta = @meta.get.merge(@labels ? { labels: @labels } : {})
          .merge(@meta.labels ? { labels: @meta.labels } : {})
        meta[:filename] = filename
        meta.transform_keys(&:to_s)
      end

      def word_section_breaks(docxml)
        @landscapestyle = ""
        word_section_breaks1(docxml, "WordSection2")
        word_section_breaks1(docxml, "WordSection3")
        word_remove_pb_before_annex(docxml)
        docxml.xpath("//br[@orientation]").each do |br|
          br.delete("orientation")
        end
      end

      def word_section_breaks1(docxml, sect)
        docxml.xpath("//div[@class = '#{sect}']//br[@orientation]").reverse
          .each_with_index do |br, i|
          @landscapestyle +=
            "\ndiv.#{sect}_#{i} {page:#{sect}" \
            "#{br['orientation'] == 'landscape' ? 'L' : 'P'};}\n"
          split_at_section_break(docxml, sect, br, i)
        end
      end

      def split_at_section_break(docxml, sect, brk, idx)
        move = brk.parent.xpath("following::node()") &
          brk.document.xpath("//div[@class = '#{sect}']//*")
        ins = docxml.at("//div[@class = '#{sect}']")
          .after("<div class='#{sect}_#{idx}'/>").next_element
        move.each do |m|
          next if m.at("./ancestor::div[@class = '#{sect}_#{idx}']")

          ins << m.remove
        end
      end
    end
  end
end
