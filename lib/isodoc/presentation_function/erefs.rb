require "metanorma-utils"
require_relative "erefs_locality"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def citeas(xmldoc)
      xmldoc.xpath(ns("//fmt-eref | //fmt-origin | //fmt-link"))
        .each do |e|
        sem_xml_descendant?(e) and next
        e["bibitemid"] && e["citeas"] or next
        a = @xrefs.anchor(e["bibitemid"], :xref, false) or next
        e["citeas"] = citeas_cleanup(a)
        # link generated in collection postprocessing from eref
        e.name == "fmt-link" && e.text.empty? and e.children = e["citeas"]
      end
    end

    def citeas_cleanup(ref)
      ref.nil? and return nil
      if ref.include?("<")
        xml = Nokogiri::XML("<root>#{ref}</root>")
        xml.xpath("//semx").each { |x| x.replace(x.children) }
        ref = to_xml(xml.at("//root").children)
      end
      ref
    end

    def expand_citeas(text)
      text.nil? and return text
      HTMLEntities.new.decode(text.gsub("&amp;#x", "&#"))
    end

    def erefstack1(elem)
      locs = elem.xpath(ns("./semx/fmt-eref")).map do |e|
        [e["connective"], to_xml(e.parent.remove)]
      end.flatten
      ret = resolve_eref_connectives(locs)
      elem.next = "<semx element='erefstack' source='#{elem['id']}'>#{l10n ret[1]}</semx>"
    end

    def resolve_eref_connectives(locs)
      locs = escape_l10n(locs)
      locs = resolve_comma_connectives(locs)
      locs = resolve_to_connectives(locs)
      locs.size < 3 and return locs
      locs = locs.each_slice(2).with_object([]) do |a, m|
        m << { conn: a[0], label: a[1] }
      end
      [", ", combine_conn(locs)]
    end

    XREF_CONNECTIVES = %w(from to or and).freeze

    def escape_l10n(locs)
      locs.map do |x|
        if XREF_CONNECTIVES.include?(x) || [", ", " ", ""].include?(x)
          x
        else
          esc x
        end
      end
    end

    def resolve_comma_connectives(locs)
      locs1 = []
      add = ""
      until locs.empty?
        locs, locs1, add = resolve_comma_connectives1(locs, locs1, add)
      end
      locs1 << add unless add.empty?
      locs1
    end

    def resolve_comma_connectives1(locs, locs1, add)
      if [", ", " ", ""].include?(locs[1])
        add += locs[0..2].join
        locs.shift(3)
      else
        locs1 << add unless add.empty?
        add = ""
        locs1 << locs.shift
      end
      [locs, locs1, add]
    end

    def resolve_to_connectives(locs)
      locs1 = []
      until locs.empty?
        if locs[1] == "to"
          locs1 << connectives_spans(@i18n.chain_to.sub("%1", locs[0])
            .sub("%2", locs[2]))
          locs.shift(3)
        else locs1 << locs.shift
        end
      end
      locs1
    end

    def eref2link(docxml)
      docxml.xpath(ns("//display-text")).each { |f| f.replace(f.children) }
      docxml.xpath(ns("//fmt-eref | //fmt-origin[not(.//termref)]"))
        .each do |e|
        sem_xml_descendant?(e) and next
        href = eref_target(e) or next
        e.xpath(ns("./locality | ./localityStack")).each(&:remove)
        if %w(short).include?(e["style"]) then eref2linkshort(e, href)
        elsif href[:type] == :anchor || %w(full).include?(e["style"])
          eref2xref(e)
        else eref2link1(e, href)
        end
      end
    end

    def eref2xref(node)
      node.name = "fmt-xref"
      node["target"] = node["bibitemid"]
      node.delete("bibitemid")
      node.delete("citeas")
      node["type"] == "footnote" and node.wrap("<sup></sup>")
    end

    def eref2link1(node, href)
      url = href[:link]
      att = href[:type] == :attachment ? "attachment='true'" : ""
      repl = "<fmt-link #{att} target='#{url}'>#{to_xml(node.children)}</link>"
      node["type"] == "footnote" and repl = "<sup>#{repl}</sup>"
      node.replace(repl)
    end

    def eref2linkshort(node, href)
      node.at(ns("./span[@class = 'fmt-first-biblio-delim']")) or
        return eref2xref(node)
      node.children = <<~XML
        <fmt-xref target='#{node['bibitemid']}'>#{to_xml(node.children).sub('<span class="fmt-first-biblio-delim"/>', '</fmt-xref>')}
      XML
    end

    def suffix_url(url)
      url.nil? || %r{^https?://|^#}.match?(url) and return url
      File.extname(url).empty? or return url
      url.sub(/#{File.extname(url)}$/, ".html")
    end

    def eref_target(node)
      u = eref_url(node["bibitemid"]) or return nil
      url = suffix_url(u[:link])
      anchor = node.at(ns(".//locality[@type = 'anchor']"))
      /^#/.match?(url) || !anchor and return { link: url, type: u[:type] }
      { link: "#{url}##{anchor.text.strip}", type: u[:type] }
    end

    def eref_url_prep(id)
      @bibitem_lookup.nil? and return nil
      @bibitem_lookup[id]
    end

    def eref_url(id)
      b = eref_url_prep(id) or return nil
      %i(attachment citation).each do |x|
        u = b.at(ns("./uri[@type = '#{x}'][@language = '#{@lang}']")) ||
          b.at(ns("./uri[@type = '#{x}']")) and return { link: u.text, type: x }
      end
      if b["hidden"] == "true"
        u = b.at(ns("./uri")) or return nil
        { link: u.text, type: :citation }
      else { link: "##{id}", type: :anchor }
      end
    end
  end
end
