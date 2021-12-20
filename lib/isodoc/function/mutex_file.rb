require "singleton"

module Metanorma
  class FileHelper
    include Singleton

    def initialize
      @semaphore = Mutex.new
    end

    def read(filename)
      @semaphore.synchronize {
        ::File.read(filename, encoding: "UTF-8")
      }
    end
  end
end
