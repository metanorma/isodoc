require_relative "refs"

module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def middle_title(docxml)
      s = docxml.at(ns("//sections")) or return
      t = @meta.get[:doctitle]
      t.nil? || t.empty? and return
      s.add_first_child "<p class='zzSTDTitle1'>#{t}</p>"
    end

    def missing_title(docxml)
      docxml.xpath(ns("//definitions[not(./title)]")).each do |d|
        # should only be happening for subclauses
        d.add_first_child "<title>#{@i18n.symbols}</title>"
      end
      docxml.xpath(ns("//foreword[not(./title)]")).each do |d|
        d.add_first_child "<title>#{@i18n.foreword}</title>"
      end
    end

    def floattitle(docxml)
      docxml.xpath(ns(".//floating-title")).each { |f| floattitle1(f) }
    end

    # TODO not currently doing anything with the @depth attribute of floating-title
    def floattitle1(elem)
      p = elem.dup
      p.children = "<semx element='floating-title' source='#{elem['id']}'>" \
        "#{to_xml(p.children)}</semx>"
      elem.next = p
      p.name = "p"
      p["type"] = "floating-title"
      transfer_id(elem, p)
    end

    def preceding_floating_titles(node, idx)
      out = node.xpath("./preceding-sibling::*")
        .reverse.each_with_object([]) do |p, m|
        %w(note admonition p floating-title).include?(p.name) or break m
        m << p
      end
      out.reject { |c| c["displayorder"] }.reverse_each do |c|
        skip_display_order?(c) and next
        c["displayorder"] = idx
        idx += 1
      end
      idx
    end

    def clausetitle(docxml)
      cjk_extended_title(docxml)
    end

    def cjk_search
      lang = %w(zh ja ko).map { |x| "@language = '#{x}'" }.join(" or ")
      %(Hans Hant Jpan Hang Kore).include?(@script) and
        lang += " or not(@language)"
      lang
    end

    def cjk_extended_title(doc)
      l = cjk_search
      doc.xpath(ns("//bibdata/title[#{l}] | //floating-title[#{l}] | " \
                   "//fmt-title[@depth = '1' or not(@depth)][#{l}]"))
        .each do |t|
        t.text.size < 4 or next
        t.traverse do |n|
          n.text? or next
          n.replace(@i18n.cjk_extend(n.text))
        end
      end
    end

    def preceding_floats(clause)
      ret = []
      p = clause
      while prev = p.previous_element
        if prev.name == "floating-title"
          ret << prev
          p = prev
        else break end
      end
      ret
    end

    def toc_title(docxml)
      docxml.at(ns("//preface/clause[@type = 'toc']")) and return
      ins = toc_title_insert_pt(docxml) or return
      ins.previous = <<~CLAUSE
        <clause type = 'toc' #{add_id_text}><fmt-title depth='1'>#{@i18n.table_of_contents}</fmt-title></clause>
      CLAUSE
    end

    def toc_title_insert_pt(docxml)
      ins = docxml.at(ns("//preface")) ||
        docxml.at(ns("//sections | //annex | //bibliography"))
          &.before("<preface> </preface>")
          &.previous_element or return nil
      ins.children.empty? and ins << " "
      ins.children.first
    end
  end
end
