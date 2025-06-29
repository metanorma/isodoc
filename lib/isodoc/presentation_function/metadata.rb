module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def metadata(docxml)
      preprocess_metadata(docxml)
      toc_metadata(docxml)
      fonts_metadata(docxml)
      attachments_extract(docxml)
      a = docxml.at(ns("//metanorma-extension")) or return
      a.elements.empty? and a.remove
    end

    def preprocess_metadata(docxml)
      localized_strings(docxml)
      logo_expand_pres_metadata(docxml)
    end

    # logo-{role}-{format}-{height/width}-{number}
    def logo_expand_pres_metadata(docxml)
      docxml.xpath(ns("//metanorma-extension/presentation-metadata/*"))
        .each do |x|
        logo_size_pres_metadata_incomplete?(x) or next
        parts = x.name.split("-")
        @output_formats.each_key do |f|
          tagname = "logo-#{parts[1]}-#{f}-#{parts[2..].join('-')}"
          x.parent.next = <<~XML
            <presentation-metadata><#{tagname}>#{x.text}</#{tagname}></presentation-metadata>
          XML
        end
      end
    end

    def logo_size_pres_metadata_incomplete?(elem)
      parts = elem.name.split("-")
      elem.name.start_with?("logo-") &&
        %w(author editor publisher authorizer distrbutor).include?(parts[1]) &&
        %w(height width).include?(parts[2])
    end

    def localized_strings(docxml)
      a = docxml.at(ns("//bibdata")) or return
      a.next =
        "<localized-strings>#{i8n_name(trim_hash(@i18n.get), '').join}" \
        "</localized-strings>"
    end

    def attachments_extract(docxml)
      docxml.at(ns("//metanorma-extension/attachment")) or return
      dir = File.join(@output_dir, "_#{@outputfile}_attachments")
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p(dir)
      docxml.xpath(ns("//metanorma-extension/attachment")).each do |a|
        save_attachment(a, dir)
      end
    end

    def save_attachment(attachment, dir)
      n = File.join(dir, File.basename(attachment["name"]))
      c = attachment.text.sub(%r{^data:[^;]+;(?:charset=[^;]+;)?base64,}, "")
      File.open(n, "wb") { |f| f.write(Base64.decode64(c)) }
    end

    def extension_insert(xml, path = [])
      ins = extension_insert_pt(xml)
      path.each do |n|
        ins = ins.at(ns("./#{n}")) || ins.add_child("<#{n}/>").first
      end
      ins
    end

    def extension_insert_pt(xml)
      xml.at(ns("//metanorma-extension")) ||
        xml.at(ns("//bibdata"))
          &.after("<metanorma-extension> </metanorma-extension>")
          &.next_element ||
        xml.root.elements.first
          .before("<metanorma-extension> </metanorma-extension>")
          .previous_element
    end

    def toc_metadata(docxml)
      @tocfigures || @toctables || @tocrecommendations or return
      ins = extension_insert(docxml)
      @tocfigures and
        ins << "<toc type='figure'><title>#{@i18n.toc_figures}</title></toc>"
      @toctables and
        ins << "<toc type='table'><title>#{@i18n.toc_tables}</title></toc>"
      @tocfigures and
        ins << "<toc type='recommendation'><title>#{@i18n.toc_recommendations}" \
        "</title></toc>"
    end

    def fonts_metadata(xmldoc)
      ins = presmeta_insert_pt(xmldoc)
      @fontist_fonts and CSV.parse_line(@fontist_fonts, col_sep: ";")
        .map(&:strip).reverse_each do |f|
        ins.next = presmeta("fonts", f)
      end
      @fontlicenseagreement and
        ins.next = presmeta("font-license-agreement", @fontlicenseagreement)
    end

    def presmeta_insert_pt(xmldoc)
      xmldoc.at(ns("//presentation-metadata")) ||
        extension_insert_pt(xmldoc).children.last
    end

    def presmeta(name, value)
      "<presentation-metadata><name>#{name}</name><value>#{value}</value>" \
        "</presentation-metadata>"
    end

    def i18n_tag(key, value)
      "<localized-string key='#{key}' language='#{@lang}'>#{value}" \
        "</localized-string>"
    end

    def i18n_safe(key)
      key.to_s.gsub(/\s|\./, "_")
    end

    def i8n_name(hash, pref)
      case hash
      when Hash then i8n_name1(hash, pref)
      when Array
        hash.reject { |a| blank?(a) }.each_with_object([])
          .with_index do |(v1, g), i|
            i8n_name(v1, "#{i18n_safe(k)}.#{i}").each { |x| g << x }
          end
      else [i18n_tag(pref, hash)]
      end
    end

    def i8n_name1(hash, pref)
      hash.reject { |_k, v| blank?(v) }.each_with_object([]) do |(k, v), g|
        case v
        when Hash then i8n_name(v, i18n_safe(k)).each { |x| g << x }
        when Array
          v.reject { |a| blank?(a) }.each_with_index do |v1, i|
            i8n_name(v1, "#{i18n_safe(k)}.#{i}").each { |x| g << x }
          end
        else
          g << i18n_tag("#{pref}#{pref.empty? ? '' : '.'}#{i18n_safe(k)}", v)
        end
      end
    end

    # https://stackoverflow.com/a/31822406
    def blank?(elem)
      elem.nil? || (elem.respond_to?(:empty?) && elem.empty?)
    end

    def trim_hash(hash)
      loop do
        h_new = trim_hash1(hash)
        break hash if hash == h_new

        hash = h_new
      end
    end

    def trim_hash1(hash)
      hash.is_a?(Hash) or return hash
      hash.each_with_object({}) do |(k, v), g|
        blank?(v) and next
        g[k] = case v
               when Hash then trim_hash1(hash[k])
               when Array
                 hash[k].map { |a| trim_hash1(a) }.reject { |a| blank?(a) }
               else v
               end
      end
    end
  end
end
