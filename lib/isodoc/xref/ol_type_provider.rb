module IsoDoc
  module XrefGen
    module OlTypeProvider
      def ol_type(list, depth)
        return list["type"].to_sym if list["type"]
        return :arabic if [2, 7].include? depth
        return :alphabet if [1, 6].include? depth
        return :alphabet_upper if [4, 9].include? depth
        return :roman if [3, 8].include? depth
        return :roman_upper if [5, 10].include? depth

        :arabic
      end
    end
  end
end
