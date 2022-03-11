module Metanorma
  module Output

    class Base

      def convert(_in_path, _out_path)
        raise "This is an abstract class"
      end

    end
  end
end
