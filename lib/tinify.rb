require "tinify/version"
require "tinify/error"

require "tinify/client"
require "tinify/result_meta"
require "tinify/result"
require "tinify/source"

require "thread"

module Tinify
  class << self
    attr_reader :key
    attr_reader :app_identifier
    attr_reader :proxy
    attr_accessor :compression_count

    def key=(key)
      @key = key
      @client = nil
    end

    def app_identifier=(app_identifier)
      @app_identifier = app_identifier
      @client = nil
    end

    def proxy=(proxy)
      @proxy = proxy
      @client = nil
    end

    def from_file(path)
      Source.from_file(path)
    end

    def from_buffer(string)
      Source.from_buffer(string)
    end

    def from_url(string)
      Source.from_url(string)
    end

    def validate!
      client.request(:post, "/shrink")
    rescue AccountError => err
      return true if err.status == 429
      raise err
    rescue ClientError
      true
    end

    @@mutex = Mutex.new

    def client
      raise AccountError.new("Provide an API key with Tinify.key = ...") unless key
      return @client if @client
      @@mutex.synchronize do
        @client ||= Client.new(key, app_identifier, proxy).freeze
      end
    end
  end
end
