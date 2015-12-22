require File.expand_path("../helper", __FILE__)

describe Tinify::Source do
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

    describe "posting json" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .with(body: "{\"source\":{\"url\":\"http://example.com/test.jpg\"}}")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}'
        )

        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .with(body: "{\"source\":{\"url\":\"file://wrong\"}}")
          .to_return(
            status: 400,
            body: '{
              "error": "Source not found",
              "message": "Cannot parse URL"
            }'
          )

        stub_request(:get, "https://api:valid@api.tinify.com/some/location").to_return(
          status: 200,
          body: "compressed file"
        )
      end

      describe "from_url" do
        it "should return source" do
          assert_kind_of Tinify::Source, Tinify::Source.from_url("http://example.com/test.jpg")
        end

        it "should return source with data" do
          assert_equal "compressed file", Tinify::Source.from_url("http://example.com/test.jpg").to_buffer
        end

        it "should raise error when server doesnt return a 200" do
          assert_raises Tinify::ClientError do
            Tinify::Source.from_url("file://wrong")
          end
        end
      end
    end

    describe "posting image binary" do
      before do
        stub_request(:post, "https://api:valid@api.tinify.com/shrink")
          .to_return(
            status: 201,
            headers: { Location: "https://api.tinify.com/some/location" },
            body: '{}'
          )

        stub_request(:get, "https://api:valid@api.tinify.com/some/location").to_return(
          status: 200,
          body: "compressed file"
        )

        stub_request(:get, "https://api:valid@api.tinify.com/some/location").with(
          body: '{"resize":{"width":400}}'
        ).to_return(
          status: 200,
          body: "small file"
        )

        stub_request(:post, "https://api:valid@api.tinify.com/some/location").with(
          body: '{"store":{"service":"s3"}}'
        ).to_return(
          status: 200,
          headers: { Location: "https://bucket.s3.amazonaws.com/example" }
        )

        stub_request(:post, "https://api:valid@api.tinify.com/some/location").with(
          body: '{"resize":{"width":400},"store":{"service":"s3"}}'
        ).to_return(
          status: 200,
          headers: { Location: "https://bucket.s3.amazonaws.com/example" }
        )
      end

      describe "from_file" do
        it "should return source" do
          assert_kind_of Tinify::Source, Tinify::Source.from_file(dummy_file)
        end

        it "should return source with data" do
          assert_equal "compressed file", Tinify::Source.from_file(dummy_file).to_buffer
        end
      end

      describe "from_buffer" do
        it "should return source" do
          assert_kind_of Tinify::Source, Tinify::Source.from_buffer("png file")
        end

        it "should return source with data" do
          assert_equal "compressed file", Tinify::Source.from_buffer("png file").to_buffer
        end
      end


      describe "result" do
        it "should return result" do
          assert_kind_of Tinify::Result, Tinify::Source.from_buffer("png file").result
        end
      end

      describe "resize" do
        it "should return source" do
          assert_kind_of Tinify::Source, Tinify::Source.from_buffer("png file").resize(width: 400)
        end

        it "should return source with data" do
          assert_equal "small file", Tinify::Source.from_buffer("png file").resize(width: 400).to_buffer
        end
      end

      describe "store" do
        it "should return result meta" do
          assert_kind_of Tinify::ResultMeta, Tinify::Source.from_buffer("png file").store(service: "s3")
        end

        it "should return result meta with location" do
          result = Tinify::Source.from_buffer("png file").store(service: "s3")
          assert_equal "https://bucket.s3.amazonaws.com/example", result.location
        end

        it "should include resize options if set" do
          result = Tinify::Source.from_buffer("png file").resize(width: 400).store(service: "s3")
          assert_equal "https://bucket.s3.amazonaws.com/example", result.location
        end
      end

      describe "to_buffer" do
        it "should return image data" do
          assert_equal "compressed file", Tinify::Source.from_buffer("png file").to_buffer
        end
      end

      describe "to_file" do
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
end
