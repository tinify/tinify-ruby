require File.expand_path("../helper", __FILE__)

describe Tinify::Client do
  subject do
    Tinify::Client.new("key")
  end

  describe "request" do
    describe "when valid" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_return(status: 200)
      end

      it "should issue request" do
        subject.request(:get, "/")
        assert_requested :get, "https://api:key@api.tinify.com",
          headers: { "Authorization" => "Basic " + ["api:key"].pack("m").chomp }
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
    end

    describe "with timeout" do
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

    describe "with socket error" do
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

    describe "with unexpected error" do
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

    describe "with server error" do
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


    describe "with bad server response" do
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
        assert_raise_with_message %r{Error while parsing response: .*unexpected token at '<!-- this is not json -->' \(HTTP 543/ParseError\)} do
          subject.request(:get, "/")
        end
      end
    end

    describe "with client error" do
      before do
        stub_request(:get, "https://api:key@api.tinify.com").to_return(
          status: 492,
          body: '{"error":"BadRequest","message":"Oops!"}'
        )
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
        )
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
