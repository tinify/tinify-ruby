require "tinify"
require "tempfile"

require "minitest/autorun"

describe "client" do
  abort "Set the TINIFY_KEY environment variable." unless ENV["TINIFY_KEY"]
  Tinify.key = ENV["TINIFY_KEY"]

  unoptimized_path = File.expand_path("../examples/voormedia.png", __FILE__)
  optimized = Tinify.from_file(unoptimized_path)

  it "should compress" do
    Tempfile.open("optimized.png") do |tmp|
      optimized.to_file(tmp.path)
      assert_operator tmp.size, :<, 1500
    end
  end

  it "should resize" do
    Tempfile.open("resized.png") do |tmp|
      optimized.resize(method: "fit", width: 50, height: 20).to_file(tmp.path)
      assert_operator tmp.size, :<, 800
    end
  end
end
