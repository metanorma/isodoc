module IsoDoc
  class PresentationXMLConvert < ::IsoDoc::Convert
    def metadata(docxml)
      toc_metadata(docxml)
      fonts_metadata(docxml)
      attachments_extract(docxml)
      preprocess_xslt_insert(docxml)
      a = docxml.at(ns("//bibdata")) or return
      a.next =
        "<localized-strings>#{i8n_name(trim_hash(@i18n.get), '').join}" \
        "</localized-strings>"
    end

    def attachments_extract(docxml)
      docxml.at(ns("//metanorma-extension/attachment")) or return
      dir = File.join(@localdir, "_#{@outputfile}_attachments")
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
        extension_insert_pt(xml).children.last
    end

    def presmeta(name, value)
      "<presentation-metadata><name>#{name}</name><value>#{value}</value>" \
        "</presentation-metadata>"
    end

    def preprocess_xslt_insert(docxml)
      content = ""
      p = passthrough_xslt and content += p
      p = preprocess_xslt_read and content += File.read(p)
      content.empty? and return
      ins = extension_insert(docxml, %w(render))
      ins << content
    end

    COPY_XSLT =
      '<xsl:copy><xsl:apply-templates select="@* | node()"/></xsl:copy>'.freeze
    COPY_CHILDREN_XSLT =
      '<xsl:apply-templates select="node()"/>'.freeze

    def xslt_template(content)
      <<~XSLT
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
          <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
          <xsl:template match="@* | node()">#{COPY_XSLT}</xsl:template>
        #{content}
        </xsl:stylesheet>
      XSLT
    end

    def passthrough_xslt
      @output_formats.nil? and return nil
      @output_formats.empty? and return nil
      @output_formats.each_key.with_object([]) do |k, m|
        m << <<~XSLT
          <preprocess-xslt format="#{k}">
            #{xslt_template(<<~XSLT1)
              <xsl:template match="*[local-name() = 'passthrough']">
                <xsl:if test="contains(@formats,',#{k},')"> <!-- delimited -->
                #{COPY_XSLT}
                </xsl:if>
              </xsl:template>
            XSLT1
            }
          </preprocess-xslt>
        XSLT
        m << <<~XSLT
          <preprocess-xslt format="#{k}">
            #{xslt_template(<<~XSLT1)
              <xsl:template match="*[local-name() = 'math-with-linebreak']">
              #{k == 'pdf' ? COPY_CHILDREN_XSLT : ''}
              </xsl:template>
              <xsl:template match="*[local-name() = 'math-no-linebreak']">
              #{k == 'pdf' ? '' : COPY_CHILDREN_XSLT}
              </xsl:template>
            XSLT1
            }
          </preprocess-xslt>
        XSLT
      end.join("\n")
    end

    # read in from file, but with `<preprocess-xslt @format="">` wrapper
    def preprocess_xslt_read
      html_doc_path("preprocess.xslt")
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
