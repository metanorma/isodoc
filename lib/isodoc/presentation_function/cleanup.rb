module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def cleanup(docxml)
      docxml["type"] = "presentation"
      empty_elements_remove(docxml)
    end

    # allow fmt-link to be empty
    def empty_elements_remove(docxml)
      %w(fmt-name fmt-xref-label fmt-source fmt-xref fmt-eref fmt-origin
         fmt-concept fmt-related fmt-preferred fmt-deprecates
         fmt-admitted fmt-termsource fmt-definition fmt-footnote-container
         fmt-fn-body fmt-fn-label fmt-annotation-body fmt-provision
         fmt-identifier fmt-date).each do |e|
           docxml.xpath(ns("//#{e}")).each do |n|
             n.text.strip.empty? or next
             n.elements.empty? or next
             n.remove
           end
         end
    end
  end
end
