module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def figure(docxml)
      docxml.xpath(ns("//figure")).each do |f|
        figure1(f)
      end
    end

    def figure1(f)
      return sourcecode1(f) if f["class"] == "pseudocode" ||
        f["type"] == "pseudocode"
      return if labelled_ancestor(f) && f.ancestors("figure").empty?
      return if f.at(ns("./figure")) and !f.at(ns("./name"))
      lbl = @xrefs.anchor(f['id'], :label, false) or return
      prefix_name(f, "&nbsp;&mdash; ", l10n("#{@figure_lbl} #{lbl}"))
    end

    def prefix_name(f, delim, number)
      return if number.nil? || number.empty?
      unless name = f.at(ns("./name"))
        f.children.first.previous = "<name></name>"
        name = f.children.first
      end
      name.children.empty? ? name.add_child(number) :
        ( name.children.first.previous = "#{number}#{delim}" )
    end

    def sourcecode(docxml)
      docxml.xpath(ns("//sourcecode")).each do |f|
        sourcecode1(f)
      end
    end

    def sourcecode1(f)
      return if labelled_ancestor(f)
      return unless f.ancestors("example").empty?
      lbl = @xrefs.anchor(f['id'], :label, false) or return
      prefix_name(f, "&nbsp;&mdash; ", l10n("#{@figure_lbl} #{lbl}"))
    end
  end
end
