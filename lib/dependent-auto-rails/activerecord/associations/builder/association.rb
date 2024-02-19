# frozen_string_literal: true

module ActiveRecord::Associations::Builder
  class Association
    def self.create_reflection(model, name, scope, options, &block)
      raise ArgumentError, "association names must be a Symbol" unless name.is_a?(Symbol)

      validate_options(options)

      extension = define_extensions(model, name, &block)
      options[:extend] = [*options[:extend], extension] if extension

      scope = build_scope(scope)

      ActiveRecord::Reflection.create(macro, name, scope, dynamic_reflection_options(model, options), model)
    end

    def self.dynamic_reflection_options(model, options)
      DynamicReflectionOptionsHash.new.merge!(
        options,
        {
          model_name: model.name,
          association_type: if self < ActiveRecord::Associations::Builder::SingularAssociation
                              :singular
                            elsif self < ActiveRecord::Associations::Builder::CollectionAssociation
                              :collection
                            else
                              raise DependentAutoRails::Error, "Unsupported association type"
                            end
        }
      )
    end
    private_class_method :dynamic_reflection_options

    class DynamicReflectionOptionsHash < Hash
      def [](key)
        return super unless key == :dependent && super(:dependent) == :auto
        return fallback_method if defining_dependent_callbacks?

        model = super(:model_name).constantize
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
end
