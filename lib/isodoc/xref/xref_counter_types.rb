require_relative "xref_counter"

module IsoDoc
  class Xref
    def clause_counter(num = 0, opts = {})
      opts[:numerals] ||= :arabic
      ::IsoDoc::XrefGen::Counter.new(num, opts)
    end

    def list_counter(num = 0, opts = {})
      ::IsoDoc::XrefGen::Counter.new(num, opts)
    end
  end
end
