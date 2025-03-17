require "bundler/setup"
Bundler.require

require "minitest/autorun"
require "webmock/minitest"
require "tinify"

WebMock.disable_net_connect!(allow_localhost: true)

module TestHelpers
  def before_setup
    Tinify.key = nil
    Tinify.proxy = nil
    super
  end

  def assert_raise_with_message(message)
    err = nil
    begin
      yield
    rescue => err
    end
    if message.is_a?(Regexp)
      assert_match(message, err.message)
    else
      assert_equal(message, err.message)
    end
  end
end

module Minitest
  class Spec
    include TestHelpers
  end
end
