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

          return @dependent_auto if defined?(@dependent_auto)
          # The method returned here is only used to define an after_commit callback
          # for :destroy_async, so it doesn't really matter what we return.
          # This helps us since we can't yet determine the correct method as
          # the associated model might not have been evaluated.
          return fallback_method if defining_dependent_callbacks?

          @dependent_auto = begin
            model = super(:association_model_name).constantize

            if executable_callbacks_on_destroy_for(model).empty?
              case super(:association_type)
              when :singular then :delete
              when :collection then :delete_all
              else fallback_method
              end
            else
              :destroy
            end
          end
        end

        private

        def defining_dependent_callbacks?
          caller.any? { |line| line.include?("active_record/associations/builder/association.rb") }
        end

        def executable_callbacks_on_destroy_for(model)
          model._find_callbacks.to_a +
            model._initialize_callbacks.to_a +
            model._destroy_callbacks.to_a +
            model._commit_callbacks.to_a +
            model._rollback_callbacks.to_a
        end

        def fallback_method
          :destroy # The safest, also common to all supported associations
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
