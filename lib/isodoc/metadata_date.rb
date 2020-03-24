module IsoDoc
  class Metadata
    MONTHS = {
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
      }.freeze

      def monthyr(isodate)
        m = /(?<yr>\d\d\d\d)-(?<mo>\d\d)/.match isodate
        return isodate unless m && m[:yr] && m[:mo]
        return "#{MONTHS[m[:mo].to_sym]} #{m[:yr]}"
      end
  end
end
