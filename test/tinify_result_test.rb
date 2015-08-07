require File.expand_path("../helper", __FILE__)

describe Tinify::Result do
  describe "with meta and data" do
    subject do
      Tinify::Result.new({
        "Image-Width" => "100",
        "Image-Height" => "60",
        "Content-Length" => "450",
        "Content-Type" => "image/png",
      }, "image data")
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
      it "should return nil" do
        assert_nil subject.location
      end
    end

    describe "size" do
      it "should return content length" do
        assert_equal 450, subject.size
      end
    end

    describe "content_type" do
      it "should return mime type" do
        assert_equal "image/png", subject.content_type
      end
    end

    describe "to_buffer" do
      it "should return image data" do
        assert_equal "image data", subject.to_buffer
      end
    end
  end
end
