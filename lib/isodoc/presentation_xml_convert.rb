module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def initialize(options)
      @format = :presentation
      @suffix = "presentation.xml"
      super
    end

    def convert1(docxml, filename, dir)
      @xrefs.parse docxml
      info docxml, nil
      figure docxml
      docxml.to_xml
    end

    def postprocess(result, filename, dir)
      #result = from_xhtml(cleanup(to_xhtml(textcleanup(result))))
      toXML(result, filename)
      @files_to_delete.each { |f| FileUtils.rm_rf f }
    end

    def toXML(result, filename)
      #result = (from_xhtml(html_cleanup(to_xhtml(result))))
      #result = from_xhtml(move_images(to_xhtml(result)))
      #result = html5(script_cdata(inject_script(result)))
      File.open(filename, "w:UTF-8") { |f| f.write(result) }
    end

    def figure(docxml)
      docxml.xpath(ns("//figure")).each do |f|
        next if labelled_ancestor(f) && f.ancestors("figure").empty?
        lbl = @xrefs.anchor(f['id'], :label, false) or next
        unless name = f.at(ns("./name"))
          next if f.at(ns("./figure"))
          f.children.first.previous = "<name></name>" 
          name = f.children.first
        end
        prefix_name(name, "&nbsp;&mdash; ", l10n("#{@figure_lbl} #{lbl}"))
      end
    end

    def prefix_name(name, delim, number)
      return if number.nil? || number.empty?
      name.children.empty? or name.children.first.previous = delim
      if name.children.empty?
        name.add_child number
      else
        name.children.first.previous = number
      end
    end
  end
end
