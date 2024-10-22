require_relative "xref_counter"

module IsoDoc
  module XrefGen
    class ClauseCounter < Counter
      def initialize(num = 0, opts = { numerals: :arabic })
        super
      end
    end
  end
end
