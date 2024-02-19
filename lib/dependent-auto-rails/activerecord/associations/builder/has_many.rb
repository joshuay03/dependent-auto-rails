# frozen_string_literal: true

module ActiveRecord::Associations::Builder
  class HasMany < CollectionAssociation
    def self.valid_dependent_options
      [:auto, :destroy, :delete_all, :nullify, :restrict_with_error, :restrict_with_exception, :destroy_async]
    end
    private_class_method :valid_dependent_options
  end
end
