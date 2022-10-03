abort "Set the TINIFY_KEY environment variable." unless ENV["TINIFY_KEY"]

require "bundler/setup"
require "tinify"

require "minitest/autorun"

describe "client integration" do
  Tinify.key = ENV["TINIFY_KEY"]
  Tinify.proxy = ENV["TINIFY_PROXY"]

  unoptimized_path = File.expand_path("../examples/voormedia.png", __FILE__)
  optimized = Tinify.from_file(unoptimized_path)

  it "should compress from file" do
    Tempfile.open("optimized.png", encoding: "binary") do |file|
      optimized.to_file(file.path)

      size = file.size
      contents = file.read

      assert_operator size, :>, 1000
      assert_operator size, :<, 1500

      # width == 137
      assert_includes contents, "\0\0\0\x89".force_encoding("binary")
      refute_includes contents, "Copyright Voormedia".force_encoding("binary")
    end
  end

  it "should compress from url" do
    source = Tinify.from_url("https://raw.githubusercontent.com/tinify/tinify-ruby/master/test/examples/voormedia.png")
    Tempfile.open("optimized.png", encoding: "binary") do |file|
      source.to_file(file.path)

      size = file.size
      contents = file.read

      assert_operator size, :>, 1000
      assert_operator size, :<, 1500

      # width == 137
      assert_includes contents, "\0\0\0\x89".force_encoding("binary")
      refute_includes contents, "Copyright Voormedia".force_encoding("binary")
    end
  end

  it "should resize" do
    Tempfile.open("optimized.png", encoding: "binary") do |file|
      optimized.resize(method: "fit", width: 50, height: 20).to_file(file.path)

      size = file.size
      contents = file.read

      assert_operator size, :>, 500
      assert_operator size, :<, 1000

      # width == 50
      assert_includes contents, "\0\0\0\x32".force_encoding("binary")
      refute_includes contents, "Copyright Voormedia".force_encoding("binary")
    end
  end

  it "should preserve metadata" do
    Tempfile.open("optimized.png", encoding: "binary") do |file|
      optimized.preserve(:copyright, :creation).to_file(file.path)

      size = file.size
      contents = file.read

      assert_operator size, :>, 1000
      assert_operator size, :<, 2000

      # width == 137
      assert_includes contents, "\0\0\0\x89".force_encoding("binary")
      assert_includes contents, "Copyright Voormedia".force_encoding("binary")
    end
  end

  it "should convert" do
    Tempfile.open("optimized.png", encoding: "binary") do |file|
      optimized.convert(type: "image/webp").to_file(file.path)
      r = file.read

      assert_equal r[0..3], "RIFF".force_encoding("binary")
      assert_equal r[8..11], "WEBP".force_encoding("binary")
    end
  end

end
