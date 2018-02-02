module IsoDoc
  class Convert

    def self.toHTML(result, filename)
      File.open("#{filename}.html", "w") do |f|
        f.write(result)
      end
    end
  end
end
