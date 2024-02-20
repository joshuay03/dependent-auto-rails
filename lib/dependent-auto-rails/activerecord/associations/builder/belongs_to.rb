# frozen_string_literal: true

module ActiveRecord::Associations::Builder
  class BelongsTo < SingularAssociation
    def self.valid_dependent_options
      [:auto, :destroy, :delete, :destroy_async]
    end
    private_class_method :valid_dependent_options
  end
end
