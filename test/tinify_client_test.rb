require File.expand_path("../helper", __FILE__)

describe Tinify::Client do
  Tinify::Client.send(:remove_const, :RETRY_DELAY)
  Tinify::Client.const_set(:RETRY_DELAY, 10)

  subject do
    Tinify::Client.new("key")
  end

  describe "request" do
    describe "when valid" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_return(
          status: 201,
          headers: { "Compression-Count" => "12" }
        )
        stub_request(:get, "https://api:key@api.tinify.com/shrink").to_return(
          status: 201,
          headers: {
            "Compression-Count" => "12",
            "Location" => "https://api.tinify.com/output/3spbi1cd7rs812lb.png"
          }
        )
      end

      it "should issue request" do
        subject.request(:get, "/")
        assert_requested :get, "https://api:key@api.tinify.com",
          headers: { "Authorization" => "Basic " + ["api:key"].pack("m").chomp }
      end

      it "should issue request to endpoint" do
        subject.request(:get, "/shrink", {})
        assert_requested :get, "https://api:key@api.tinify.com/shrink"
      end

      it "should issue request with method" do
        subject.request(:get, "/shrink", {})
        assert_requested :get, "https://api:key@api.tinify.com/shrink"
      end

      it "should return response" do
        response = subject.request(:get, "/shrink", {})
        assert_equal "https://api.tinify.com/output/3spbi1cd7rs812lb.png", response.headers["Location"]
      end

      it "should issue request without body when options are empty" do
        subject.request(:get, "/", {})
        assert_requested :get, "https://api:key@api.tinify.com", body: nil
      end

      it "should issue request without content type when options are empty" do
        subject.request(:get, "/", {})
        assert_not_requested :get, "https://api:key@api.tinify.com",
          headers: { "Content-Type" => "application/x-www-form-urlencoded" }
      end

      it "should issue request with json body" do
        subject.request(:get, "/", { hello: "world" })
        assert_requested :get, "https://api:key@api.tinify.com",
          headers: { "Content-Type" => "application/json" },
          body: '{"hello":"world"}'
      end

      it "should issue request with user agent" do
        subject.request(:get, "/")
        assert_requested :get, "https://api:key@api.tinify.com",
          headers: { "User-Agent" => Tinify::Client::USER_AGENT }
      end

      it "should update compression count" do
        subject.request(:get, "/")
        assert_equal 12, Tinify.compression_count
      end

      describe "with app id" do
        subject do
          Tinify::Client.new("key", "TestApp/0.1")
        end

        it "should issue request with user agent" do
          subject.request(:get, "/")
          assert_requested :get, "https://api:key@api.tinify.com",
            headers: { "User-Agent" => "#{Tinify::Client::USER_AGENT} TestApp/0.1" }
        end
      end

      describe "with proxy" do
        subject do
          Tinify::Client.new("key", nil, "http://user:pass@localhost:8080")
        end

        it "should issue request with proxy authorization" do
          subject.request(:get, "/")
          assert_requested :get, "https://api:key@api.tinify.com",
            headers: { "Proxy-Authorization" => "Basic dXNlcjpwYXNz" }
        end
      end
    end

    describe "with timeout once" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_timeout
          .then.to_return(status: 201)
      end

      it "should return response" do
        response = subject.request(:get, "/")
        assert_equal "", response.body
      end
    end

    describe "with timeout repeatedly" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_timeout
      end

      it "should raise connection error" do
        assert_raises Tinify::ConnectionError do
          subject.request(:get, "/")
        end
      end

      it "should raise error with message" do
        assert_raise_with_message "Timeout while connecting" do
          subject.request(:get, "/")
        end
      end
    end

    describe "with socket error once" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com")
          .to_raise(SocketError.new("nodename nor servname provided"))
          .then.to_return(status: 201)
      end

      it "should return response" do
        response = subject.request(:get, "/")
        assert_equal "", response.body
      end
    end

    describe "with socket error repeatedly" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_raise(SocketError.new("nodename nor servname provided"))
      end

      it "should raise error" do
        assert_raises Tinify::ConnectionError do
          subject.request(:get, "/")
        end
      end

      it "should raise error with message" do
        assert_raise_with_message "Error while connecting: nodename nor servname provided" do
          subject.request(:get, "/")
        end
      end
    end

    describe "with unexpected error once" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com")
          .to_raise("some error")
          .then.to_return(status: 201)
      end

      it "should return response" do
        response = subject.request(:get, "/")
        assert_equal "", response.body
      end
    end

    describe "with unexpected error repeatedly" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_raise("some error")
      end

      it "should raise error" do
        assert_raises Tinify::ConnectionError do
          subject.request(:get, "/")
        end
      end

      it "should raise error with message" do
        assert_raise_with_message "Error while connecting: some error" do
          subject.request(:get, "/")
        end
      end
    end

    describe "with server error once" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_return(
          status: 584,
          body: '{"error":"InternalServerError","message":"Oops!"}'
        ).then.to_return(status: 201)
      end

      it "should return response" do
        response = subject.request(:get, "/")
        assert_equal "", response.body
      end
    end

    describe "with server error repeatedly" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_return(
          status: 584,
          body: '{"error":"InternalServerError","message":"Oops!"}'
        )
      end

      it "should raise server error" do
        assert_raises Tinify::ServerError do
          subject.request(:get, "/")
        end
      end

      it "should raise error with message" do
        assert_raise_with_message "Oops! (HTTP 584/InternalServerError)" do
          subject.request(:get, "/")
        end
      end
    end

    describe "with bad server response once" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_return(
          status: 543,
          body: '<!-- this is not json -->'
        ).then.to_return(status: 201)
      end

      it "should return response" do
        response = subject.request(:get, "/")
        assert_equal "", response.body
      end
    end

    describe "with bad server response repeatedly" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_return(
          status: 543,
          body: '<!-- this is not json -->'
        )
      end

      it "should raise server error" do
        assert_raises Tinify::ServerError do
          subject.request(:get, "/")
        end
      end

      it "should raise error with message" do
        # NOTE: hacky implementation for truffle and jruby.
        begin
          subject.request(:get, "/")
        rescue => e
          assert e.message
                  .include?("'<!-- this is not json -->' (HTTP 543/ParseError)")
        end
      end
    end

    describe "with client error" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_return(
          status: 492,
          body: '{"error":"BadRequest","message":"Oops!"}'
        ).then.to_return(status: 201)
      end

      it "should raise client error" do
        assert_raises Tinify::ClientError do
          subject.request(:get, "/")
        end
      end

      it "should raise error with message" do
        assert_raise_with_message "Oops! (HTTP 492/BadRequest)" do
          subject.request(:get, "/")
        end
      end
    end


    describe "with bad credentials" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_return(
          status: 401,
          body: '{"error":"Unauthorized","message":"Oops!"}'
        ).then.to_return(status: 201)
      end

      it "should raise account error" do
        assert_raises Tinify::AccountError do
          subject.request(:get, "/")
        end
      end

      it "should raise error with message" do
        assert_raise_with_message "Oops! (HTTP 401/Unauthorized)" do
          subject.request(:get, "/")
        end
      end
    end
  end
end
