module IsoDoc
  class Metadata
    DATETYPES =
      %w{published accessed created implemented obsoleted confirmed updated
         corrected issued received transmitted copied unchanged circulated
         adapted announced vote-started vote-ended stable-until}.freeze

    def months
      {
        "01": @labels["month_january"],
        "02": @labels["month_february"],
        "03": @labels["month_march"],
        "04": @labels["month_april"],
        "05": @labels["month_may"],
        "06": @labels["month_june"],
        "07": @labels["month_july"],
        "08": @labels["month_august"],
        "09": @labels["month_september"],
        "10": @labels["month_october"],
        "11": @labels["month_november"],
        "12": @labels["month_december"],
      }
    end

    def monthyr(isodate)
      m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)/.match isodate
      return isodate unless m && m[:yr] && m[:mo]

      l10n("#{months[m[:mo].to_sym]} #{m[:yr]}")
    end

    def MMMddyyyy(isodate)
      isodate.nil? and return nil

      arr = isodate.split("-")
      arr.size == 1 && (/^\d+$/.match isodate) and
        return Date.new(*arr.map(&:to_i)).strftime("%Y")
      arr.size == 2 and
        return Date.new(*arr.map(&:to_i)).strftime("%B %Y")
      Date.parse(isodate).strftime("%B %d, %Y")
    end

    def bibdate(isoxml, _out)
      isoxml.xpath(ns("//bibdata/date")).each do |d|
        set("#{d['type'].tr('-', '_')}date".to_sym, Common::date_range(d))
      end
    end
  end
end
