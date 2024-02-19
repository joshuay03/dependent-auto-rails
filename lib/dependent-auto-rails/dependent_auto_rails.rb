# frozen_string_literal: true

require "active_record"

ActiveSupport.on_load(:active_record) do
  require_relative "activerecord/associations/builder/association"
end

module DependentAutoRails
  class Error < StandardError; end
end
