# frozen_string_literal: true

require "minitest/autorun"
require "active_support/testing/assertions"

class Minitest::Test
  include ActiveSupport::Testing::Assertions
end

require_relative "../lib/dependent-auto-rails"
