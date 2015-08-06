module Tinify
  class Result < ResultMeta
    attr_reader :data

    def initialize(meta, data)
      @meta, @data = meta.freeze, data.freeze
    end

    def to_file(path)
      File.open(path, "wb") { |file| file.write(data) }
    end

    alias_method :to_buffer, :data

    def size
      @meta["Content-Length"].to_i
    end

    def media_type
      @meta["Content-Type"]
    end
    alias_method :content_type, :media_type
  end
end
