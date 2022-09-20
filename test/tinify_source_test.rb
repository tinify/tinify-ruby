require File.expand_path("../helper", __FILE__)

describe Tinify::Source do
  dummy_file = File.expand_path("../examples/dummy.png", __FILE__)

  describe "with invalid api key" do
    before do
      Tinify.key = "invalid"

      stub_request(:post, "https://api:invalid@api.tinify.com/shrink")
        .to_return(
          status: 401,
          body: '{"error":"Unauthorized","message":"Credentials are invalid"}')
    end

    describe "from_file" do
      it "should raise account error" do
        assert_raises Tinify::AccountError do
          Tinify::Source.from_file(dummy_file)
        end
      end
    end

    describe "from_buffer" do
      it "should raise account error" do
        assert_raises Tinify::AccountError do
          Tinify::Source.from_buffer("png file")
        end
      end
    end

    describe "from_url" do
      it "should raise account error" do
        assert_raises Tinify::AccountError do
          Tinify::Source.from_url("http://example.com/test.jpg")
        end
      end
    end
  end

  describe "with valid api key" do
    before do
      Tinify.key = "valid"
    end

    describe "from_file" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location")
          .to_return(
            status: 200,
            body: "compressed file")
      end

      it "should return source" do
        assert_kind_of Tinify::Source, Tinify::Source.from_file(dummy_file)
      end

      it "should return source with data" do
        assert_equal "compressed file", Tinify::Source.from_file(dummy_file).to_buffer
      end
    end

    describe "from_buffer" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location")
          .to_return(
            status: 200,
            body: "compressed file")
      end

      it "should return source" do
        assert_kind_of Tinify::Source, Tinify::Source.from_buffer("png file")
      end

      it "should return source with data" do
        assert_equal "compressed file", Tinify::Source.from_buffer("png file").to_buffer
      end
    end

    describe "from_url" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .with(body: '{"source":{"url":"http://example.com/test.jpg"}}')
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .with(body: '{"source":{"url":"file://wrong"}}')
          .to_return(
            status: 400,
            body: '{"error":"Source not found","message":"Cannot parse URL"}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location")
          .to_return(
            status: 200,
            body: "compressed file")
      end

      it "should return source" do
        assert_kind_of Tinify::Source, Tinify::Source.from_url("http://example.com/test.jpg")
      end

      it "should return source with data" do
        assert_equal "compressed file", Tinify::Source.from_url("http://example.com/test.jpg").to_buffer
      end

      it "should raise error if request is not ok" do
        assert_raises Tinify::ClientError do
          Tinify::Source.from_url("file://wrong")
        end
      end
    end

    describe "result" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location")
          .to_return(
            status: 200,
            body: "compressed file")
      end

      it "should return result" do
        assert_kind_of Tinify::Result, Tinify::Source.from_buffer("png file").result
      end
    end

    describe "preserve" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location")
          .with(
            body: '{"preserve":["copyright","location"]}')
          .to_return(
            status: 200,
            body: "copyrighted file")
      end

      it "should return source" do
        source = Tinify::Source.from_buffer("png file").preserve(:copyright, :location)
        assert_kind_of Tinify::Source, source
      end

      it "should return source with data" do
        source = Tinify::Source.from_buffer("png file").preserve(:copyright, :location)
        assert_equal "copyrighted file", source.to_buffer
      end

      it "should return source with data for array" do
        source = Tinify::Source.from_buffer("png file").preserve([:copyright, :location])
        assert_equal "copyrighted file", source.to_buffer
      end

      it "should include other options if set" do
        stub_request(:get, "https://api:valid@api.tinify.com/some/location")
          .with(
            body: '{"resize":{"width":400},"preserve":["copyright","location"]}')
          .to_return(
            status: 200,
            body: "copyrighted resized file")

        source = Tinify::Source.from_buffer("png file").resize(width: 400).preserve(:copyright, :location)
        assert_equal "copyrighted resized file", source.to_buffer
      end
    end

    describe "resize" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location")
          .with(
            body: '{"resize":{"width":400}}')
          .to_return(
            status: 200,
            body: "small file")
      end

      it "should return source" do
        assert_kind_of Tinify::Source, Tinify::Source.from_buffer("png file").resize(width: 400)
      end

      it "should return source with data" do
        assert_equal "small file", Tinify::Source.from_buffer("png file").resize(width: 400).to_buffer
      end
    end

    describe "convert" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location")
          .with(
            body: '{"convert":{"type":["image/webp"]}}')
          .to_return(
            status: 200,
            body: "converted file")
      end

      it "should return source" do
        assert_kind_of Tinify::Source, Tinify::Source.from_buffer("png file").convert(type: ["image/webp"])
      end

      it "should return source with data" do
        assert_equal "converted file", Tinify::Source.from_buffer("png file").convert(type: ["image/webp"]).to_buffer
      end
    end

    describe "transform" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location")
          .with(
            body: '{"transform":{"color":"black"}}')
          .to_return(
            status: 200,
            body: "transformd file")
      end

      it "should return source" do
        assert_kind_of Tinify::Source, Tinify::Source.from_buffer("png file").transform(color: "black'")
      end

      it "should return source with data" do
        assert_equal "transformd file", Tinify::Source.from_buffer("png file").transform(color: "black").to_buffer
      end

      it "should include other options if set" do

        stub_request(:get, "https://api:valid@api.tinify.com/some/location").
        with(:body => '{"convert":{"type":["image/webp"]},"transform":{"color":"black"}}',
            ).
        to_return(:status => 200, :body => "trans-formed-and-coded", :headers => {})

        result = Tinify::Source.from_buffer("png file").convert(type: ["image/webp"]).transform(color: "black")
        assert_equal "trans-formed-and-coded", result.to_buffer
      end


    end

    describe "store" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}'
          )

        stub_request(:post, "https://api:valid@api.tinify.com/some/location")
        .with(
          body: '{"store":{"service":"s3"}}')
        .to_return(
          status: 200,
          headers: { Location: "https://bucket.s3.amazonaws.com/example" })
      end

      it "should return result meta" do
        assert_kind_of Tinify::ResultMeta, Tinify::Source.from_buffer("png file").store(service: "s3")
      end

      it "should return result meta with location" do
        result = Tinify::Source.from_buffer("png file").store(service: "s3")
        assert_equal "https://bucket.s3.amazonaws.com/example", result.location
      end

      it "should include other options if set" do
        stub_request(:post, "https://api:valid@api.tinify.com/some/location")
        .with(
          body: '{"resize":{"width":400},"store":{"service":"s3"}}')
        .to_return(
          status: 200,
          headers: { Location: "https://bucket.s3.amazonaws.com/example" })

        result = Tinify::Source.from_buffer("png file").resize(width: 400).store(service: "s3")
        assert_equal "https://bucket.s3.amazonaws.com/example", result.location
      end
    end

    describe "to_buffer" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location").to_return(
          status: 200,
          body: "compressed file"
        )
      end

      it "should return image data" do
        assert_equal "compressed file", Tinify::Source.from_buffer("png file").to_buffer
      end
    end

    describe "to_file" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}')

        stub_request(:get, "https://api:valid@api.tinify.com/some/location").to_return(
          status: 200,
          body: "compressed file"
        )
      end

      it "should store image data" do
        begin
          tmp = Tempfile.open("foo")
          Tinify::Source.from_buffer("png file").to_file(tmp.path)
          assert_equal "compressed file", File.binread(tmp.path)
        ensure
          tmp.unlink
        end
      end
    end
  end
end
