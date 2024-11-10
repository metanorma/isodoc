module IsoDoc
  module XrefGen
    module Sections
      def clause_order(docxml)
        { preface: clause_order_preface(docxml),
          main: clause_order_main(docxml),
          annex: clause_order_annex(docxml),
          back: clause_order_back(docxml) }
      end

      def clause_order_preface(_docxml)
        [{ path: "//preface/*", multi: true }]
      end

      def clause_order_main(docxml)
        [
          { path: "//sections/clause[@type = 'scope']" },
          { path: @klass.norm_ref_xpath },
          { path: "//sections/terms | " \
            "//sections/clause[descendant::terms]", multi: true },
          { path: "//sections/definitions | " \
            "//sections/clause[descendant::definitions]" \
            "[not(descendant::terms)]", multi: true },
          { path: @klass.middle_clause(docxml), multi: true },
        ]
      end

      def clause_order_annex(_docxml)
        [{ path: "//annex", multi: true }]
      end

      def clause_order_back(_docxml)
        [
          { path: @klass.bibliography_xpath },
          { path: "//indexsect", multi: true },
          { path: "//colophon/*", multi: true },
        ]
      end
    end
  end
end
