# frozen_string_literal: true

require "active_record"
require "active_support"

ActiveSupport.on_load(:active_record) do
  require "dependent-auto-rails/activerecord/associations/builder/belongs_to"
  require "dependent-auto-rails/activerecord/associations/builder/has_one"
  require "dependent-auto-rails/activerecord/associations/builder/has_many"
  require "dependent-auto-rails/activerecord/associations/builder/association"
end

module DependentAutoRails
  class Error < StandardError; end
end
