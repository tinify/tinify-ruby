require File.expand_path("../helper", __FILE__)

describe Tinify::ResultMeta do
  describe "with metadata" do
    subject do
      Tinify::ResultMeta.new({
        "Image-Width" => "100",
        "Image-Height" => "60",
        "Location" => "https://example.com/image.png",
      })
    end

    describe "width" do
      it "should return image width" do
        assert_equal 100, subject.width
      end
    end

    describe "height" do
      it "should return image height" do
        assert_equal 60, subject.height
      end
    end

    describe "location" do
      it "should return image location" do
        assert_equal "https://example.com/image.png", subject.location
      end
    end
  end
end
