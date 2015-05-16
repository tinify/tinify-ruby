require File.expand_path("../helper", __FILE__)

describe Tinify do
  dummy_file = File.expand_path("../examples/dummy.png", __FILE__)

  describe "reset" do
    it "should reset key" do
      Tinify.key = "abcde"
      Tinify.reset!
      assert_equal nil, Tinify.key
    end
  end
end
