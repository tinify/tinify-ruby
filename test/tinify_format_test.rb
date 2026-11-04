require File.expand_path("../helper", __FILE__)

describe Tinify::Format do
  describe "constants" do
    it "should expose the supported media types" do
      assert_equal "image/webp", Tinify::Format::WEBP
      assert_equal "image/png", Tinify::Format::PNG
      assert_equal "image/jpeg", Tinify::Format::JPEG
      assert_equal "image/jpg", Tinify::Format::JPG
      assert_equal "image/avif", Tinify::Format::AVIF
      assert_equal "image/jxl", Tinify::Format::JXL
      assert_equal "*/*", Tinify::Format::ANY
    end
  end

  describe "convert" do
    before do
      Tinify.key = "valid"

      stub_request(:post, "https://api.tinify.com/shrink")
        .with(basic_auth: ['api', 'valid'])
        .to_return(
          status: 201,
          headers: { Location: "https://api.tinify.com/some/location" },
          body: '{}')
    end

    it "should serialize a single format" do
      stub_request(:post, "https://api.tinify.com/some/location")
        .with(
          basic_auth: ['api', 'valid'],
          body: '{"convert":{"type":"image/jxl"}}')
        .to_return(
          status: 200,
          body: "converted file")

      source = Tinify::Source.from_buffer("png file")
        .convert(type: Tinify::Format::JXL)
      assert_equal "converted file", source.to_buffer
    end

    it "should serialize multiple formats" do
      stub_request(:post, "https://api.tinify.com/some/location")
        .with(
          basic_auth: ['api', 'valid'],
          body: '{"convert":{"type":["image/jxl","image/webp"]}}')
        .to_return(
          status: 200,
          body: "converted file")

      source = Tinify::Source.from_buffer("png file")
        .convert(type: [Tinify::Format::JXL, Tinify::Format::WEBP])
      assert_equal "converted file", source.to_buffer
    end
  end
end
