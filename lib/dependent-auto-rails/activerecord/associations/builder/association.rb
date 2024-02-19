# frozen_string_literal: true

module ActiveRecord::Associations::Builder
  class Association
    def self.build(model, name, scope, options, &block)
      if model.dangerous_attribute_method?(name)
        raise ArgumentError, "You tried to define an association named #{name} on the model #{model.name}, but " \
                             "this will conflict with a method #{name} already defined by Active Record. " \
                             "Please choose a different association name."
      end

      if options[:dependent] == :auto
        options[:dependent] = if model._destroy_callbacks.empty?
          :destroy
        else
          :delete
        end
      end

      reflection = create_reflection(model, name, scope, options, &block)
      define_accessors model, reflection
      define_callbacks model, reflection
      define_validations model, reflection
      define_change_tracking_methods model, reflection
      reflection
    end
  end
end
