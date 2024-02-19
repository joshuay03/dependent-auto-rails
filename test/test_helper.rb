# frozen_string_literal: true

require "dependent-auto-rails/dependent_auto_rails"

require "minitest/autorun"
require "active_support/testing/assertions"

class Minitest::Test
  include ActiveSupport::Testing::Assertions
end
