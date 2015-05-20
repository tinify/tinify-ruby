module Tinify
  class Image
    class << self
      def from_file(path)
        from_buffer(File.open(path, "rb") { |file| file.read })
      end

      def from_buffer(string)
        response = Tinify.client.request(:post, "/shrink", string)
        new(response.headers["Location"]).freeze
      end
    end

    def initialize(url, commands = {})
      @url, @commands = url.freeze, commands.freeze
    end

    def resize(options)
      self.class.new(@url, @commands.merge(resize: options))
    end

    def to_file(path)
      File.open(path, "wb") { |file| file.write(to_buffer) }
    end

    def to_buffer
      Tinify.client.request(:get, @url, @commands).body
    end
  end
end
