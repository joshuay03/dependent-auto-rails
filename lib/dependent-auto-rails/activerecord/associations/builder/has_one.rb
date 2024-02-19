# frozen_string_literal: true

module ActiveRecord::Associations::Builder
  class HasOne < SingularAssociation
    def self.valid_dependent_options
      [:auto, :destroy, :destroy_async, :delete, :nullify, :restrict_with_error, :restrict_with_exception]
    end
    private_class_method :valid_dependent_options
  end
end
