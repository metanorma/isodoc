
module IsoDoc
  module ClassUtils

    def date_range(date)
      from = date.at(ns("./from"))
      to = date.at(ns("./to"))
      on = date.at(ns("./on"))
      return on.text if on
      ret = "#{from.text}&ndash;"
      ret += to.text if to
      ret
    end

    def ns(xpath)
      xpath.gsub(%r{/([a-zA-z])}, "/xmlns:\\1").
        gsub(%r{::([a-zA-z])}, "::xmlns:\\1").
        gsub(%r{\[([a-zA-z][a-z0-9A-Z@/]* ?=)}, "[xmlns:\\1").
        gsub(%r{\[([a-zA-z][a-z0-9A-Z@/]*\])}, "[xmlns:\\1")
    end

  end

end