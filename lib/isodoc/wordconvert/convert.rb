require "uuidtools"
require "html2doc"
require "liquid"

require_relative "wordconvertmodule"
require_relative "comments"
require_relative "footnotes"

module IsoDoc

  module WordConvertModule
    # http://tech.tulentsev.com/2012/02/ruby-how-to-override-class-method-with-a-module/
    # https://www.ruby-forum.com/topic/148303
    #
    # The following is ugly indeed, but the only way I can split module override methods
    # across files
    def self.included base
      base.class_eval do

        eval File.open(File.join(File.dirname(__FILE__),"wordconvertmodule.rb")).read
        eval File.open(File.join(File.dirname(__FILE__),"comments.rb")).read
        eval File.open(File.join(File.dirname(__FILE__),"footnotes.rb")).read
        eval File.open(File.join(File.dirname(__FILE__),"postprocess.rb")).read
      end
    end
  end

  class WordConvert < Convert
    include WordConvertModule
  end
end

