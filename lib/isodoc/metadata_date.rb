module IsoDoc
  class Metadata
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
        IsoDoc::Function::I18n::l10n("#{months[m[:mo].to_sym]} #{m[:yr]}",
                                     @lang, @script)
      end
  end
end
