require "httpclient"
require "json"

module Tinify
  class Client
    API_ENDPOINT = "https://api.tinify.com".freeze

    RETRY_COUNT = 1

    USER_AGENT = "Tinify/#{VERSION} Ruby/#{RUBY_VERSION}p#{RUBY_PATCHLEVEL} (#{defined?(RUBY_ENGINE) ? RUBY_ENGINE : "unknown"})".freeze

    CA_BUNDLE = File.expand_path("../../data/cacert.pem", __FILE__).freeze

    def initialize(key, app_identifier = nil, proxy = nil)
      begin
        @client = HTTPClient.new(proxy)
      rescue ArgumentError => err
        raise ConnectionError.new("Invalid proxy: #{err.message}")
      end

      @client.base_url = API_ENDPOINT
      @client.default_header = { "User-Agent" => [USER_AGENT, app_identifier].compact.join(" ") }

      @client.force_basic_auth = true
      @client.set_auth("/", "api", key)

      @client.ssl_config.clear_cert_store
      @client.ssl_config.add_trust_ca(CA_BUNDLE)
    end

    def request(method, url, body = nil, header = {})
      if Hash === body
        if body.empty?
          body = nil
        else
          body = JSON.generate(body)
          header["Content-Type"] = "application/json"
        end
      end

      RETRY_COUNT.downto(0) do |retries|
        begin
          response = @client.request(method, url, body: body, header: header)
        rescue HTTPClient::TimeoutError => err
          next if retries > 0
          raise ConnectionError.new("Timeout while connecting")
        rescue StandardError => err
          next if retries > 0
          raise ConnectionError.new("Error while connecting: #{err.message}")
        end

        if count = response.headers["Compression-Count"]
          Tinify.compression_count = count.to_i
        end

        return response if response.ok?

        details = begin
          JSON.parse(response.body)
        rescue StandardError => err
          {"message" => "Error while parsing response: #{err.message}", "error" => "ParseError"}
        end
        next if retries > 0 and response.status >= 500
        raise Error.create(details["message"], details["error"], response.status)
      end
    end
  end
end
