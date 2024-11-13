module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def recommendation(docxml)
      docxml.xpath(ns("//recommendation")).each do |f|
        recommendation1(f, lower2cap(f["class"]) ||
                        lower2cap(@i18n.recommendation))
      end
    end

    def requirement(docxml)
      docxml.xpath(ns("//requirement")).each do |f|
        recommendation1(f, lower2cap(f["class"]) ||
                        lower2cap(@i18n.requirement))
      end
    end

    def permission(docxml)
      docxml.xpath(ns("//permission")).each do |f|
        recommendation1(f, lower2cap(f["class"]) ||
                        lower2cap(@i18n.permission))
      end
    end

    def recommendation1(elem, type)
      lbl = @reqt_models.model(elem["model"])
        .recommendation_label(elem, type, xrefs)
      prefix_name(elem, {}, l10n(lbl), "name")
    end

    def requirement_render_preprocessing(docxml); end

    REQS = %w(requirement recommendation permission).freeze

    def requirement_render(docxml)
      requirement_render_preprocessing(docxml)
      REQS.each do |x|
        REQS.each do |y|
          docxml.xpath(ns("//#{x}//#{y}")).each { |r| requirement_render1(r) }
        end
      end
      docxml.xpath(ns("//requirement | //recommendation | //permission"))
        .each { |r| requirement_render1(r) }
    end

    def requirement_render1(node)
      node.replace(@reqt_models.model(node["model"])
        .requirement_render1(node))
    end
  end
end
