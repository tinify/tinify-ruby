module Tinify
  class Source
    class << self
      def from_file(path)
        from_buffer(File.open(path, "rb") { |file| file.read })
      end

      def from_buffer(string)
        response = Tinify.client.request(:post, "/shrink", string)
        new(response.headers["Location"]).freeze
      end

      def from_url(url)
        response = Tinify.client.request(:post, "/shrink", source: { url: url })
        new(response.headers["Location"]).freeze
      end
    end

    def initialize(url, commands = {})
      @url, @commands = url.freeze, commands.freeze
    end

    def preserve(*options)
      options = Array(options).flatten
      self.class.new(@url, @commands.merge(preserve: options))
    end

    def resize(options)
      self.class.new(@url, @commands.merge(resize: options))
    end

    def store(options)
      response = Tinify.client.request(:post, @url, @commands.merge(store: options))
      ResultMeta.new(response.headers).freeze
    end

    def result
      response = Tinify.client.request(:get, @url, @commands)
      Result.new(response.headers, response.body).freeze
    end

    def to_file(path)
      result.to_file(path)
    end

    def to_buffer
      result.to_buffer
    end
  end
end
