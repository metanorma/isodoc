require_relative "xref_counter"

module IsoDoc
  class Xref
    def class_counter(num = 0, opts = { numerals: :arabic })
      ::IsoDoc::XrefGen::Counter.new(num, opts)
    end
  end
end
