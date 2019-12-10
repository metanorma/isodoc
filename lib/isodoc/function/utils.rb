module IsoDoc::Function
  module Utils
    def date_range(date)
      self.class.date_range(date)
    end

    def ns(xpath)
      self.class.ns(xpath)
    end

    def insert_tab(out, n)
      [1..n].each { out << "&nbsp; " }
    end

    # add namespaces for Word fragments
    NOKOHEAD = <<~HERE.freeze
    <!DOCTYPE html SYSTEM
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head> <title></title> <meta charset="UTF-8" /> </head>
    <body> </body> </html>
    HERE

    # block for processing XML document fragments as XHTML,
    # to allow for HTMLentities
    def noko(&block)
      doc = ::Nokogiri::XML.parse(NOKOHEAD)
      fragment = doc.fragment("")
      ::Nokogiri::XML::Builder.with fragment, &block
      fragment.to_xml(encoding: "US-ASCII").lines.map do |l|
        l.gsub(/\s*\n/, "")
      end
    end

    def attr_code(attributes)
      attributes = attributes.reject { |_, val| val.nil? }.map
      attributes.map do |k, v|
        [k, (v.is_a? String) ? HTMLEntities.new.decode(v) : v]
      end.to_h
    end

    DOCTYPE_HDR = '<!DOCTYPE html SYSTEM '\
      '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'.freeze

    def to_xhtml(xml)
      xml.gsub!(/<\?xml[^>]*>/, "")
      /<!DOCTYPE /.match xml or xml = DOCTYPE_HDR + xml
      xml = xml.split(/(\&[^ \r\n\t#;]+;)/).map do |t|
        /^(\&[^ \t\r\n#;]+;)/.match(t) ? 
          HTMLEntities.new.encode(HTMLEntities.new.decode(t), :hexadecimal) : t
      end.join("")
      Nokogiri::XML.parse(xml)
    end

    def to_xhtml_fragment(xml)
      doc = ::Nokogiri::XML.parse(NOKOHEAD)
      fragment = doc.fragment(xml)
      fragment
    end

    def from_xhtml(xml)
      xml.to_xml.sub(%r{ xmlns="http://www.w3.org/1999/xhtml"}, "")
    end

    CLAUSE_ANCESTOR =
      ".//ancestor::*[local-name() = 'annex' or "\
      "local-name() = 'appendix' or local-name() = 'foreword' or "\
      "local-name() = 'introduction' or local-name() = 'terms' or "\
      "local-name() = 'clause' or local-name() = 'references']/@id".freeze

    def get_clause_id(node)
      clause = node.xpath(CLAUSE_ANCESTOR)
      clause&.last&.text || nil
    end

    NOTE_CONTAINER_ANCESTOR =
      ".//ancestor::*[local-name() = 'annex' or "\
      "local-name() = 'foreword' or local-name() = 'appendix' or "\
      "local-name() = 'introduction' or local-name() = 'terms' or "\
      "local-name() = 'clause' or local-name() = 'references' or "\
      "local-name() = 'figure' or local-name() = 'formula' or "\
      "local-name() = 'table' or local-name() = 'example']/@id".freeze

    def get_note_container_id(node)
      container = node.xpath(NOTE_CONTAINER_ANCESTOR)
      container&.last&.text || nil
    end

    def sentence_join(array)
      return "" if array.nil? || array.empty?
      if array.length == 1 then array[0]
      else
        IsoDoc::Function::I18n::l10n("#{array[0..-2].join(', ')} "\
                                     "#{@and_lbl} #{array.last}",
                                     @lang, @script)
      end
    end

    # avoid `; avoid {{ (Liquid Templates); avoid [[ (Javascript)
    def extract_delims(text)
      @openmathdelim = "(#("
      @closemathdelim = ")#)"
      while text.include?(@openmathdelim) || text.include?(@closemathdelim)
        @openmathdelim += "("
        @closemathdelim += ")"
      end
      [@openmathdelim, @closemathdelim]
    end

    def header_strip(h)
      h = h.to_s.gsub(%r{<br/>}, " ").sub(/<\/?h[123456][^>]*>/, "")
      h1 = to_xhtml_fragment(h.dup)
      h1.traverse do |x|
        x.replace(" ") if x.name == "span" && /mso-tab-count/.match(x["style"])
        x.remove if x.name == "span" && x["class"] == "MsoCommentReference"
        x.remove if x.name == "a" && x["epub:type"] == "footnote"
        x.remove if x.name == "span" && /mso-bookmark/.match(x["style"])
        x.replace(x.children) if x.name == "a"
      end
      from_xhtml(h1)
    end

    def liquid(doc)
      self.class.liquid(doc)
    end

    def liquid(doc)
      # unescape HTML escapes in doc
      doc = doc.split(%r<(\{%|%\})>).each_slice(4).map do |a|
        a[2] = a[2].gsub(/\&lt;/, "<").gsub(/\&gt;/, ">") if a.size > 2
        a.join("")
      end.join("")
      Liquid::Template.parse(doc)
    end

    def empty2nil(v)
      return nil if !v.nil? && v.is_a?(String) && v.empty?
      v
    end

    def populate_template(docxml, _format)
      meta = @meta.get.merge(@labels || {})
      docxml = docxml.
        gsub(/\[TERMREF\]\s*/, l10n("[#{@source_lbl}: ")).
        gsub(/\s*\[MODIFICATION\]\s*\[\/TERMREF\]/, l10n(", #{@modified_lbl} [/TERMREF]")).
        gsub(/\s*\[\/TERMREF\]\s*/, l10n("]")).
        gsub(/\s*\[MODIFICATION\]/, l10n(", #{@modified_lbl} &mdash; "))
      template = liquid(docxml)
      template.render(meta.map { |k, v| [k.to_s, empty2nil(v)] }.to_h).
        gsub('&lt;', '&#x3c;').gsub('&gt;', '&#x3e;').gsub('&amp;', '&#x26;')
    end

    def save_dataimage(uri, relative_dir = true)
      %r{^data:image/(?<imgtype>[^;]+);base64,(?<imgdata>.+)$} =~ uri
      #uuid = UUIDTools::UUID.random_create.to_s
      #fname = "#{uuid}.#{imgtype}"
      #new_file = File.join(tmpimagedir, fname)
      #@files_to_delete << new_file
      #File.open(new_file, "wb") { |f| f.write(Base64.strict_decode64(imgdata)) }
      #File.join(relative_dir ? rel_tmpimagedir : tmpimagedir, fname)
      imgtype = "png" unless /^[a-z0-9]+$/.match imgtype
      Tempfile.open(["image", ".#{imgtype}"]) do |f|
        f.binmode
        f.write(Base64.strict_decode64(imgdata))
        @tempfile_cache << f #persist to the end
        f.path
      end
    end

    def image_localfile(i)
      if /^data:image/.match i["src"]
        save_dataimage(i["src"], false)
      elsif %r{^([A-Z]:)?/}.match i["src"]
        i["src"]
      else
        File.join(@localdir, i["src"])
      end
    end
  end
end
