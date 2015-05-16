require File.expand_path("../helper", __FILE__)

describe Tinify::Image do
  dummy_file = File.expand_path("../examples/dummy.png", __FILE__)

  describe "with invalid api key" do
    before do
      Tinify.key = "invalid"

      stub_request(:post, "https://api:invalid@api.tinify.com/shrink").to_return(
        status: 401,
        body: '{"error":"Unauthorized","message":"Credentials are invalid"}'
      )
    end

    describe "from_file" do
      it "should raise account error" do
        assert_raises Tinify::AccountError do
          Tinify.from_file(dummy_file)
        end
      end
    end

    describe "from_buffer" do
      it "should raise account error" do
        assert_raises Tinify::AccountError do
          Tinify.from_buffer("png file")
        end
      end
    end
  end

  describe "with valid api key" do
    before do
      Tinify.key = "valid"

      stub_request(:post, "https://api:valid@api.tinify.com/shrink").to_return(
        status: 201,
        headers: { Location: "https://api.tinify.com/some/location" },
        body: '{}'
      )

      stub_request(:get, "https://api:valid@api.tinify.com/some/location").to_return(
        status: 200,
        body: "compressed file"
      )

      stub_request(:get, "https://api:valid@api.tinify.com/some/location").with(body: '{"resize":{"width":400}}').to_return(
        status: 200,
        body: "small file"
      )
    end

    describe "from_file" do
      it "should return image" do
        assert_kind_of Tinify::Image, Tinify.from_file(dummy_file)
      end

      it "should return image with data" do
        assert_equal "compressed file", Tinify.from_file(dummy_file).to_buffer
      end
    end

    describe "from_buffer" do
      it "should return image" do
        assert_kind_of Tinify::Image, Tinify.from_buffer("png file")
      end

      it "should return image with data" do
        assert_equal "compressed file", Tinify.from_buffer("png file").to_buffer
      end
    end

    describe "resize" do
      it "should return image" do
        assert_kind_of Tinify::Image, Tinify.from_buffer("png file").resize(width: 400)
      end

      it "should return image with data" do
        assert_equal "small file", Tinify.from_buffer("png file").resize(width: 400).to_buffer
      end
    end

    describe "to_buffer" do
      it "should return image data" do
        assert_equal "compressed file", Tinify.from_buffer("png file").to_buffer
      end
    end

    describe "to_file" do
      it "should store image data" do
        begin
          tmp = Tempfile.open("foo")
          Tinify.from_buffer("png file").to_file(tmp.path)
          assert_equal "compressed file", File.binread(tmp.path)
        ensure
          tmp.unlink
        end
      end
    end
  end
end
