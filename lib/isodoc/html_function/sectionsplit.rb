require "metanorma"
require "yaml"

module IsoDoc::HtmlFunction
  module Html
    # assume we pass in Presentation XML, but we want to recover Semantic XML
    def sectionsplit_convert(input_filename, file, debug, output_filename = nil)
      input_filename += ".xml" unless input_filename.match?(/\.xml$/)
      File.exist?(input_filename) or
        File.open(input_filename, "w:UTF-8") { |f| f.write(file) }
      orig_filename = input_filename.sub(/presentation.xml$/, "xml")
      origxml = File.read(orig_filename, encoding: "utf-8")
      presxml = File.read(input_filename, encoding: "utf-8")
      @openmathdelim, @closemathdelim = extract_delims(origxml)
      xml, filename, dir = convert_init(presxml, input_filename, debug)
      build_collection(xml, presxml, output_filename || filename, dir)
    end

    def build_collection(xml, presxml, filename, dir)
      collection_setup(filename, dir)
      files = sectionsplit(xml, filename, dir)
      collection_manifest(filename, files, xml, presxml, dir).render(
        format: %i(html), output_folder: "#{filename}_collection",
        coverpage: File.join(dir, "cover.html")
      )
    end

    def collection_manifest(filename, files, origxml, presxml, dir)
      File.open(File.join(dir, "#{filename}.html.yaml"), "w:UTF-8") do |f|
        f.write(collectionyaml(files, origxml))
      end
      Metanorma::Collection.parse File.join(dir, "#{filename}.html.yaml")
    end

    def collection_setup(filename, dir)
      FileUtils.mkdir_p "#{filename}_collection"
      FileUtils.mkdir_p dir
      File.open(File.join(dir, "cover.html"), "w:UTF-8") do |f|
        f.write(coll_cover)
      end
    end

    def coll_cover
      <<~COVER
        <html>
          <head/>
            <body>
              <h1>{{ doctitle }}</h1>
              <h2>{{ docnumber }}</h2>
              <nav>{{ labels["navigation"] }}</nav>
            </body>
        </html>
      COVER
    end

    def sectionsplit(xml, filename, dir)
      xref_preprocess(xml)
      out = emptydoc(xml)
      ret = []
      ret << sectionfile(out, dir, "#{filename}.0", xml.at(ns("//preface")),
                         nil)
      xml.xpath(ns("//sections/*")).each do |s|
        ret << sectionfile(out, dir, "#{filename}.#{ret.size}", s, "sections")
      end
      xml.xpath(ns("//annex")).each do |s|
        ret << sectionfile(out, dir, "#{filename}.#{ret.size}", s, nil)
      end
      xml.xpath(ns("//bibliography/*")).each do |s|
        # hidden biblio is kept in out
        next if s.name == "references" && s["hidden"] == "true"

        ret << sectionfile(out, dir, "#{filename}.#{ret.size}", s,
                           "bibliography")
      end
      xml.xpath(ns("//indexsect")).each do |s|
        ret << sectionfile(out, dir, "#{filename}.#{ret.size}", s, nil)
      end
      ret
    end

    def emptydoc(xml)
      out = xml.dup
      out.xpath(
        ns("//preface | //sections | //annex | //bibliography/clause | "\
           "//bibliography/references[not(@hidden = 'true')] | //indexsect")
      ).each(&:remove)
      out
    end

    def sectionfile(xml, dir, file, chunk, parentnode)
      out = xml.dup
      ins = out.at(ns("//misccontainer")) || out.at(ns("//bibdata"))
      if parentnode
        ins.next = "<#{parentnode}/>"
        ins.next.add_child(chunk.dup)
      else
        ins.next = chunk.dup
      end
      File.open(File.join(dir, "#{file}.xml"), "w:UTF-8") { |f| f.write(out) }
      "#{file}.xml"
    end

    def xref_preprocess(xml)
      key = (0...8).map { rand(65..90).chr }.join # random string
      refs = eref_to_internal_eref(xml, key)
      refs += xref_to_internal_eref(xml, key)
      xml.root["type"] = key # to force recognition of internal refs
      insert_indirect_biblio(xml, refs, key)
    end

    def make_anchor(anchor)
      "<localityStack><locality type='anchor'><referenceFrom>"\
        "#{anchor}</referenceFrom></locality></localityStack>"
    end

    def xref_to_internal_eref(xml, key)
      xml.xpath(ns("//xref")).each_with_object({}) do |x, m|
        x["bibitemid"] = "#{key}_#{x['target']}"
        x << make_anchor(x["target"])
        m[x["bibitemid"]] = true
        x.delete("target")
        x["type"] = key
        x.name = "eref"
      end.keys
    end

    def eref_to_internal_eref(xml, key)
      eref_to_internal_eref_select(xml).each_with_object([]) do |x, m|
        url = xml.at(ns("//bibitem[@id = '#{x}']/url[@type = 'citation']"))
        xml.xpath(("//*[@bibitemid = '#{x}']")).each do |e|
          id = eref_to_internal_eref1(e, key, url)
          id and m << id
        end
      end
    end

    def eref_to_internal_eref1(elem, key, url)
      if url
        elem.name = "link"
        elem["target"] = url
        nil
      else
        elem["bibitemid"] = "#{key}_#{elem['bibitemid']}"
        elem << make_anchor(elem["bibitemid"])
        elem["type"] = key
        elem["bibitemid"]
      end
    end

    def eref_to_internal_eref_select(xml)
      refs = xml.xpath(("//*/@bibitemid")).map { |x| x.text } # rubocop:disable Style/SymbolProc
      refs.uniq.reject do |x|
        xml.at(ns("//bibitem[@id = '#{x}'][@type = 'internal']"))
      end
    end

    # from standoc
    def insert_indirect_biblio(xmldoc, refs, prefix)
      ins = xmldoc.at("bibliography") or
        xmldoc.root << "<bibliography/>" and ins = xmldoc.at("bibliography")
      ins = ins.add_child("<references hidden='true' normative='false'/>").first
      refs.each do |x|
        ins << <<~BIBENTRY
          <bibitem id="#{x}" type="internal">
          <docidentifier type="repository">#{x.sub(/^#{prefix}_/, "#{prefix}/")}</docidentifier>
          </bibitem>
        BIBENTRY
      end
    end

    def recursive_string_keys(hash)
      case hash
      when Hash then Hash[
        hash.map { |k, v| [k.to_s, recursive_string_keys(v)] }
      ]
      when Enumerable then hash.map { |v| recursive_string_keys(v) }
      else
        hash
      end
    end

    def titlerender(section)
      title = section.at(ns("./title")) or return "[Untitled]"
      t = title.dup
      t.xpath(ns(".//tab | .//br")).each { |x| x.replace(" ") }
      t.children.to_xml
    end

    # TODO refactor in isodoc xpaths of clauses in rendering order;
    # also to be used in xref for each flavour
    def sectionnames(xml)
      ret = [@i18n.preface]
      xml.xpath(ns("//sections/*")).each do |s|
        ret << titlerender(s)
      end
      xml.xpath(ns("//annex")).each do |s|
        ret << titlerender(s)
      end
      xml.xpath(ns("//bibliography/*")).each do |s|
        next if s.name == "references" && s["hidden"] == "true"

        ret << titlerender(s)
      end
      xml.xpath(ns("//indexsect")).each do |s|
        ret << titlerender(s)
      end
      ret
    end

    def collectionyaml(files, xml)
      names = sectionnames(xml)
      ret = {
        directives: ["presentation-xml", "bare-after-first"],
        bibdata: {
          title: {
            type: "title-main",
            language: @lang,
            content: xml.at(ns("//bibdata/title")).text,
          },
          type: "collection",
          docid: {
            type: xml.at(ns("//bibdata/docidentifier/@type")).text,
            id: xml.at(ns("//bibdata/docidentifier")).text,
          },
        },
        manifest: {
          level: "collection",
          title: "Collection",
          docref: files.each_with_index.map do |f, i|
            { fileref: f, identifier: names[i] }
          end,
        },
      }
      recursive_string_keys(ret).to_yaml
    end
  end
end
