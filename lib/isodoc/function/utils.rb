# frozen_string_literal: true

module IsoDoc::Function
  module Utils
    def date_range(date)
      self.class.date_range(date)
    end

    def ns(xpath)
      self.class.ns(xpath)
    end

    def insert_tab(out, n)
      tab = %w(Hans Hant).include?(@script) ? "&#x3000;" : "&nbsp; "
      [1..n].each { out << tab }
    end

    # add namespaces for Word fragments
    NOKOHEAD = <<~HERE
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
        [k, v.is_a?(String) ? HTMLEntities.new.decode(v) : v]
      end.to_h
    end

    DOCTYPE_HDR = '<!DOCTYPE html SYSTEM '\
      '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'

    def to_xhtml(xml)
      xml.gsub!(/<\?xml[^>]*>/, "")
      /<!DOCTYPE /.match(xml) || (xml = DOCTYPE_HDR + xml)
      xml = xml.split(/(\&[^ \r\n\t#;]+;)/).map do |t|
        /^(\&[^ \t\r\n#;]+;)/.match?(t) ?
          HTMLEntities.new.encode(HTMLEntities.new.decode(t), :hexadecimal) : t
      end.join("")
      begin
        Nokogiri::XML.parse(xml, &:strict)
      rescue Nokogiri::XML::SyntaxError => e
        File.open("#{@filename}.#{@format}.err", "w:UTF-8") { |f| f.write xml }
        abort "Malformed Output XML for #{@format}: #{e} "\
          "(see #{@filename}.#{@format}.err)"
      end
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
      "local-name() = 'definitions' or "\
      "local-name() = 'acknowledgements' or local-name() = 'term' or "\
      "local-name() = 'appendix' or local-name() = 'foreword' or "\
      "local-name() = 'introduction' or local-name() = 'terms' or "\
      "local-name() = 'clause' or local-name() = 'references']/@id"

    def get_clause_id(node)
      clause = node.xpath(CLAUSE_ANCESTOR)
      clause&.last&.text || nil
    end

    NOTE_CONTAINER_ANCESTOR =
      ".//ancestor::*[local-name() = 'annex' or "\
      "local-name() = 'foreword' or local-name() = 'appendix' or "\
      "local-name() = 'introduction' or local-name() = 'terms' or "\
      "local-name() = 'acknowledgements' or local-name() = 'term' or "\
      "local-name() = 'clause' or local-name() = 'references' or "\
      "local-name() = 'figure' or local-name() = 'formula' or "\
      "local-name() = 'table' or local-name() = 'example']/@id"

    def get_note_container_id(node)
      container = node.xpath(NOTE_CONTAINER_ANCESTOR)
      container&.last&.text || nil
    end

    def sentence_join(array)
      return '' if array.nil? || array.empty?
      if array.length == 1 then array[0]
      else
        @i18n.l10n("#{array[0..-2].join(', ')} "\
                   "#{@i18n.and} #{array.last}",
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
      h = h.to_s.gsub(%r{<br\s*/>}, " ").gsub(/<\/?h[123456][^>]*>/, "")
        .gsub(/<\/?b[^>]*>/, "")
      h1 = to_xhtml_fragment(h.dup)
      h1.traverse do |x|
        x.replace(" ") if x.name == "span" && /mso-tab-count/.match(x["style"])
        x.remove if x.name == "img"
        x.remove if x.name == "span" && x["class"] == "MsoCommentReference"
        x.remove if x.name == "a" && x["class"] == "FootnoteRef"
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

    def populate_template(docxml, _format = nil)
      meta = @meta
        .get
        .merge(@labels ? {labels: @labels} : {})
        .merge(@meta.labels ? {labels: @meta.labels} : {})
        .merge(fonts_options || {})
      template = liquid(docxml)
      template.render(meta.map { |k, v| [k.to_s, empty2nil(v)] }.to_h)
        .gsub("&lt;", "&#x3c;").gsub("&gt;", "&#x3e;").gsub("&amp;", "&#x26;")
    end

    def save_dataimage(uri, _relative_dir = true)
      %r{^data:(image|application)/(?<imgtype>[^;]+);base64,(?<imgdata>.+)$} =~ uri
      imgtype.sub!(/\+[a-z0-9]+$/, "") # svg+xml
      imgtype = "png" unless /^[a-z0-9]+$/.match imgtype
      Tempfile.open(["image", ".#{imgtype}"]) do |f|
        f.binmode
        f.write(Base64.strict_decode64(imgdata))
        @tempfile_cache << f # persist to the end
        f.path
      end
    end

    def image_localfile(i)
      if /^data:/.match? i["src"]
        save_dataimage(i["src"], false)
      elsif %r{^([A-Z]:)?/}.match? i["src"]
        i["src"]
      else
        File.join(@localdir, i["src"])
      end
    end

    def labelled_ancestor(node)
      !node.ancestors("example, requirement, recommendation, permission, "\
                      "note, table, figure, sourcecode").empty?
    end
  end
end
