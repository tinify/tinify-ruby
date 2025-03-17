require File.expand_path("../helper", __FILE__)

describe Tinify do
  dummy_file = File.expand_path("../examples/dummy.png", __FILE__)

  describe "key" do
    before do
      stub_request(:get, "https://api.tinify.com")
        .with(basic_auth: ['api', 'fghij'])
        .to_return(status: 200)
    end

    it "should reset client with new key" do
      Tinify.key = "abcde"
      Tinify.client
      Tinify.key = "fghij"
      Tinify.client.request(:get, "/")
      assert_requested :get, "https://api.tinify.com",
        headers: { "Authorization" => "Basic #{ Base64.strict_encode64('api:fghij').chomp}" }
    end
  end

  describe "app_identifier" do
    before do
      stub_request(:get, "https://api.tinify.com")
        .with(basic_auth: ['api', 'abcde'])
        .to_return(status: 200)
    end

    it "should reset client with new app identifier" do
      Tinify.key = "abcde"
      Tinify.app_identifier = "MyApp/1.0"
      Tinify.client
      Tinify.app_identifier = "MyApp/2.0"
      Tinify.client.request(:get, "/")
      assert_requested :get, "https://api.tinify.com",
        headers: { "User-Agent" => "#{Tinify::Client::USER_AGENT} MyApp/2.0" }
    end
  end

  describe "proxy" do
    before do
      stub_request(:get, "https://api.tinify.com")
        .with(basic_auth: ['api', 'abcde'])
        .to_return(status: 200)
    end

    it "should reset client with new proxy" do
      Tinify.key = "abcde"
      Tinify.proxy = "http://localhost"
      Tinify.client
      Tinify.proxy = "http://user:pass@localhost:8080"
      Tinify.client.request(:get, "/")
      assert_requested :get, "https://api.tinify.com",
        headers: { "Proxy-Authorization" => "Basic dXNlcjpwYXNz" }
    end
  end

  describe "client" do
    describe "with key" do
      it "should return client" do
        Tinify.key = "abcde"
        assert_kind_of Tinify::Client, Tinify.client
      end
    end

    describe "without key" do
      it "should raise error" do
        assert_raises Tinify::AccountError do
          Tinify.client
        end
      end
    end

    describe "with invalid proxy" do
      it "should raise error" do
        assert_raises Tinify::ConnectionError do
          Tinify.key = "abcde"
          Tinify.proxy = "http-bad-url"
          Tinify.client
        end
      end
    end
  end

  describe "validate" do
    describe "with valid key" do
      before do
        Tinify.key = "valid"

        stub_request(:post, "https://api.tinify.com/shrink")
          .with(basic_auth: ['api', 'valid'])
          .to_return(
            status: 400,
            body: '{"error":"Input missing","message":"No input"}'
          )
      end

      it "should return true" do
        assert_equal true, Tinify.validate!
      end
    end

    describe "with limited key" do
      before do
        Tinify.key = "valid"

        stub_request(:post, "https://api.tinify.com/shrink")
          .with(basic_auth: ['api', 'valid'])
          .to_return(
            status: 429,
            body: '{"error":"Too many requests","message":"Your monthly limit has been exceeded"}'
          )
      end

      it "should return true" do
        assert_equal true, Tinify.validate!
      end
    end

    describe "with error" do
      before do
        Tinify.key = "invalid"

        stub_request(:post, "https://api.tinify.com/shrink")
          .with(basic_auth: ['api', 'invalid'])
          .to_return(
            status: 401,
            body: '{"error":"Unauthorized","message":"Credentials are invalid"}'
          )
      end

      it "should raise error" do
        assert_raises Tinify::AccountError do
          Tinify.validate!
        end
      end
    end
  end

  describe "from_buffer" do
    before do
      Tinify.key = "valid"

      stub_request(:post, "https://api.tinify.com/shrink")
        .with(basic_auth: ['api', 'valid'])
        .to_return(
          status: 201,
          headers: { Location: "https://api.tinify.com/some/location" },
          body: '{}'
        )
    end

    it "should return source" do
      assert_kind_of Tinify::Source, Tinify.from_buffer("png file")
    end
  end

  describe "from_file" do
    before do
      Tinify.key = "valid"

      stub_request(:post, "https://api.tinify.com/shrink")
        .with(basic_auth: ['api', 'valid'])
        .to_return(
          status: 201,
          headers: { Location: "https://api.tinify.com/some/location" },
          body: '{}'
        )
    end

    it "should return source" do
      assert_kind_of Tinify::Source, Tinify.from_file(dummy_file)
    end
  end

  describe "from_url" do
    before do
      Tinify.key = "valid"

      stub_request(:post, "https://api.tinify.com/shrink")
        .with(basic_auth: ['api', 'valid'])
        .to_return(
          status: 201,
          headers: { Location: "https://api.tinify.com/some/location" },
          body: '{}'
        )
    end

    it "should return source" do
      assert_kind_of Tinify::Source, Tinify.from_url("http://example.com/test.jpg")
    end
  end
end
