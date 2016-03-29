abort "Set the TINIFY_KEY environment variable." unless ENV["TINIFY_KEY"]

require "bundler/setup"
require "tinify"

require "minitest/autorun"

describe "client integration" do
  Tinify.key = ENV["TINIFY_KEY"]

  unoptimized_path = File.expand_path("../examples/voormedia.png", __FILE__)
  optimized = Tinify.from_file(unoptimized_path)

  it "should compress from file" do
    Tempfile.open("optimized.png") do |file|
      optimized.to_file(file.path)
      assert_operator file.size, :>, 0
      assert_operator file.size, :<, 1500
    end
  end

  it "should compress from url" do
    source = Tinify.from_url("https://raw.githubusercontent.com/tinify/tinify-ruby/master/test/examples/voormedia.png")
    Tempfile.open("optimized.png") do |file|
      source.to_file(file.path)
      assert_operator file.size, :>, 0
      assert_operator file.size, :<, 1500
    end
  end

  it "should resize" do
    Tempfile.open("resized.png") do |file|
      optimized.resize(method: "fit", width: 50, height: 20).to_file(file.path)
      assert_operator file.size, :>, 0
      assert_operator file.size, :<, 1000
    end
  end
end
