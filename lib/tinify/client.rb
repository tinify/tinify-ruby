require "httpclient"
require "json"

require "tinify/error"

module Tinify
  class Client
    API_ENDPOINT = "https://api.tinify.com".freeze
    USER_AGENT = "Tinify/#{VERSION} Ruby/#{RUBY_VERSION}p#{RUBY_PATCHLEVEL}".freeze
    CA_BUNDLE = File.expand_path("../../data/cacert.pem", __FILE__).freeze

    def initialize(key, app_identifier = nil)
      @client = HTTPClient.new
      @client.base_url = API_ENDPOINT
      @client.default_header = { user_agent: [USER_AGENT, app_identifier].compact.join(" ") }

      @client.force_basic_auth = true
      @client.set_auth("/", "api", key)

      @client.ssl_config.clear_cert_store
      @client.ssl_config.add_trust_ca(CA_BUNDLE)
    end

    def request(method, url, body = nil, header = {})
      if Hash === body && !body.empty?
        body = JSON.generate(body)
        header["Content-Type"] = "application/json"
      end

      begin
        response = @client.request(method, url, body: body, header: header)
      rescue HTTPClient::TimeoutError => err
        raise ConnectionError.new("Timeout while connecting")
      rescue StandardError => err
        raise ConnectionError.new("Error while connecting: #{err.message}")
      end

      if response.ok?
        response
      else
        details = begin
          JSON.parse(response.body)
        rescue StandardError => err
          { "message" => "Error while parsing response: #{err.message}", "error" => "ParseError" }
        end
        raise Error.create(details["message"], details["error"], response.status)
      end
    end
  end
end
