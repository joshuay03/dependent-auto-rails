# frozen_string_literal: true

require "active_record"

ActiveSupport.on_load(:active_record) do
  require_relative "dependent-auto-rails/activerecord/associations/builder/belongs_to"
  require_relative "dependent-auto-rails/activerecord/associations/builder/has_one"
  require_relative "dependent-auto-rails/activerecord/associations/builder/has_many"
  require_relative "dependent-auto-rails/activerecord/reflection"
end

module DependentAutoRails
  class Error < StandardError; end
end
