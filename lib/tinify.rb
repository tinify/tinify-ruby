require "tinify/version"
require "tinify/client"
require "tinify/image"

require "thread"

module Tinify
  class << self
    attr_accessor :key
    attr_accessor :app_identifier

    def from_file(path)
      Image.from_file(path)
    end

    def from_buffer(string)
      Image.from_buffer(string)
    end

    def reset!
      @key = nil
      @client = nil
    end

    @@mutex = Mutex.new

    def client
      return @client if @client
      @@mutex.synchronize do
        @client ||= Client.new(@key, @app_identifier).freeze
      end
    end
  end
end
