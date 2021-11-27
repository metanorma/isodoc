module IsoDoc
  module ClassUtils
    def date_range(date)
      from = date.at(ns("./from"))
      to = date.at(ns("./to"))
      on = date.at(ns("./on"))
      return date.text unless from || on || to
      return on.text if on

      ret = "#{from.text}&ndash;"
      ret += to.text if to
      ret
    end

    def ns(xpath)
      xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1")
        .gsub(%r{::([a-zA-z])}, "::xmlns:\\1")
        .gsub(%r{\[([a-zA-z][a-z0-9A-Z@/]* ?=)}, "[xmlns:\\1")
        .gsub(%r{\[([a-zA-z][a-z0-9A-Z@/]*[/\]])}, "[xmlns:\\1")
    end

    def liquid(doc)
      # unescape HTML escapes in doc
      doc = doc.split(%r<(\{%|%\})>).each_slice(4).map do |a|
        a[2] = a[2].gsub("&lt;", "<").gsub("&gt;", ">") if a.size > 2
        a.join
      end.join
      Liquid::Template.parse(doc)
    end

    def case_strict(text, casing, script)
      return text unless %w(Latn Cyrl Grek Armn).include?(script)

      letters = text.chars
      case casing
      when "capital" then letters.first.upcase!
      when "lowercase" then letters.first.downcase!
      end
      letters.join
    end

    def case_with_markup(linkend, casing, script)
      seen = false
      xml = Nokogiri::XML("<root>#{linkend}</root>")
      xml.traverse do |b|
        next unless b.text? && !seen

        b.replace(Common::case_strict(b.text, casing, script))
        seen = true
      end
      xml.root.children.to_xml
    end
  end
end
