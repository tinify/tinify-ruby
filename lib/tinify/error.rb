module Tinify
  class Error < StandardError
    class << self
      def create(message, type, status)
        klass = case status
        when 401, 429 then AccountError
        when 400..499 then ClientError
        when 500..599 then ServerError
        else Error
        end

        message = "No message was provided" if message.to_s.empty?
        klass.new(message, type, status)
      end
    end

    def initialize(message, type = self.class.name.split("::").last, status = nil)
      @message, @type, @status = message, type, status
    end

    def message
      if @status
        "#{@message} (HTTP #{@status}/#{@type})"
      else
        "#{@message}"
      end
    end
    alias_method :to_s, :message
  end

  class AccountError < Error; end
  class ClientError < Error; end
  class ServerError < Error; end
  class ConnectionError < Error; end
end
