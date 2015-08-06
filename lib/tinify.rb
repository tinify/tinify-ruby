require "tinify/version"
require "tinify/error"

require "tinify/client"
require "tinify/result_meta"
require "tinify/result"
require "tinify/source"

require "thread"

module Tinify
  class << self
    attr_accessor :key
    attr_accessor :app_identifier
    attr_accessor :compression_count

    def key=(key)
      @key = key
      @client = nil
    end

    def from_file(path)
      Source.from_file(path)
    end

    def from_buffer(string)
      Source.from_buffer(string)
    end

    def validate!
      client.request(:post, "/shrink")
    rescue ClientError
      true
    end

    @@mutex = Mutex.new

    def client
      raise AccountError.new("Provide an API key with Tinify.key = ...") unless @key
      return @client if @client
      @@mutex.synchronize do
        @client ||= Client.new(@key, @app_identifier).freeze
      end
    end
  end
end
