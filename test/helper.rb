require "minitest/autorun"
require "webmock/minitest"

require "tinify"

module TestHelpers
  def before_setup
    Tinify.reset!
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

class MiniTest::Spec
  include TestHelpers
end
