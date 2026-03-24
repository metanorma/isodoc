require "metanorma-utils"

module IsoDoc
  module Function
    module Utils
      def save_dataimage(uri, _relative_dir = true)
        %r{^data:(?<imgclass>image|application)/(?<imgtype>[^;]+);(?:charset=[^;]+;)?base64,(?<imgdata>.+)$} =~ uri
        imgtype = "emf" if emf?("#{imgclass}/#{imgtype}")
        imgtype = imgtype.sub(/\+[a-z0-9]+$/, "") # svg+xml
        imgtype = "png" unless /^[a-z0-9]+$/.match? imgtype
        imgtype == "postscript" and imgtype = "eps"
        Tempfile.open(["image", ".#{imgtype}"],
                      mode: File::BINARY | File::SHARE_DELETE) do |f|
          f.binmode
          f.write(Base64.strict_decode64(imgdata))
          @tempfile_cache << f # persist to the end
          f.path
        end
      end

      def save_svg(img)
        Tempfile.open(["image", ".svg"],
                      mode: File::BINARY | File::SHARE_DELETE) do |f|
          f.write(img.to_xml)
          @tempfile_cache << f # persist to the end
          f.path
        end
      end

      def image_localfile(img)
        img.name == "svg" && !img["src"] and
          return save_svg(img)
        case img["src"]
        when /^data:/ then save_dataimage(img["src"], false)
        when %r{^([A-Z]:)?/} then img["src"]
        when nil then nil
        else File.join(@localdir, img["src"])
        end
      end

      def emf?(type)
        %w(application/emf application/x-emf image/x-emf image/x-mgx-emf
           application/x-msmetafile image/x-xbitmap image/emf).include? type
      end

      def eps?(type)
        %w(application/postscript image/x-eps).include? type
      end

      def imgfile_suffix(uri, suffix)
        "#{File.join(File.dirname(uri), File.basename(uri, '.*'))}.#{suffix}"
      end
    end
  end
end
