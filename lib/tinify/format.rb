module Tinify
  # Media types that images can be converted to.
  #
  # Use these constants with Source#convert:
  #
  #   Tinify.from_file("input.png")
  #     .convert(type: Tinify::Format::JXL)
  #     .to_file("output.jxl")
  #
  # Multiple types may be supplied, in which case the API returns the smallest
  # result:
  #
  #   convert(type: [Tinify::Format::JXL, Tinify::Format::WEBP])
  module Format
    # WebP.
    WEBP = "image/webp".freeze

    # PNG.
    PNG = "image/png".freeze

    # JPEG.
    JPEG = "image/jpeg".freeze

    # JPEG, an alias of JPEG.
    JPG = "image/jpg".freeze

    # AVIF.
    AVIF = "image/avif".freeze

    # JPEG XL.
    JXL = "image/jxl".freeze

    # Wildcard, returns the smallest of the supported types.
    ANY = "*/*".freeze
  end
end
