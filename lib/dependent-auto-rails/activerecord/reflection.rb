# frozen_string_literal: true

module ActiveRecord
  module Reflection
    class AssociationReflection < MacroReflection
      private

      def convert_options_to_dynamic_reflection_options!
        @options = DynamicReflectionOptionsHash.new.merge!(
          @options,
          {
            association_model_name: class_name,
            association_type: collection? ? :collection : :singular
          }
        )
      end

      class DynamicReflectionOptionsHash < Hash
        def [](key)
          return super unless key == :dependent && super(:dependent) == :auto
          return fallback_method if defining_dependent_callbacks?

          model = super(:association_model_name).constantize
          return :destroy unless valid_destroy_callbacks(model).empty?

          case super(:association_type)
          when :singular then :delete
          when :collection then :delete_all
          else fallback_method
          end
        end

        private

        def fallback_method
          :destroy
        end

        def defining_dependent_callbacks?
          caller.any? { |line| line.include?("active_record/associations/builder/association.rb") }
        end

        def valid_destroy_callbacks(model)
          model._destroy_callbacks.reject do |callback|
            # ignore #handle_dependency callback
            callback.filter.to_s.include?("active_record/associations/builder/association.rb")
          end
        end
      end
    end

    class BelongsToReflection < AssociationReflection
      def initialize(...)
        super(...)
        convert_options_to_dynamic_reflection_options!
      end
    end

    class HasOneReflection < AssociationReflection
      def initialize(...)
        super(...)
        convert_options_to_dynamic_reflection_options!
      end
    end

    class HasManyReflection < AssociationReflection
      def initialize(...)
        super(...)
        convert_options_to_dynamic_reflection_options!
      end
    end

    class HasAndBelongsToManyReflection < AssociationReflection
      def initialize(...)
        super(...)
        convert_options_to_dynamic_reflection_options!
      end
    end
  end
end
