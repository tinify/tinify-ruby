module Tinify
  class ResultMeta
    def initialize(meta)
      @meta = meta.freeze
    end

    def width
      @meta["Image-Width"].to_i.nonzero?
    end

    def height
      @meta["Image-Height"].to_i.nonzero?
    end

    def location
      @meta["Location"]
    end
  end
end
