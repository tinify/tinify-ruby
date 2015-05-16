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

    def initialize(url, instructions = {})
      @url, @instructions = url.freeze, instructions.freeze
    end

    def resize(options)
      self.class.new(@url, @instructions.merge(resize: options))
    end

    def to_file(path)
      File.open(path, "wb") { |file| file.write(to_buffer) }
    end

    def to_buffer
      Tinify.client.request(:get, @url, @instructions).body
    end
  end
end
