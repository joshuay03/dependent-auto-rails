# frozen_string_literal: true

module ActiveRecord::Associations::Builder
  class HasMany < CollectionAssociation
    def self.valid_dependent_options
      [:auto, :destroy, :delete_all, :nullify, :restrict_with_error, :restrict_with_exception, :destroy_async]
    end
    private_class_method :macro, :valid_options, :valid_dependent_options
  end
end

module ActiveRecord
  module Associations
    class HasManyAssociation < CollectionAssociation
      def handle_dependency
        case options[:dependent]
        when :restrict_with_exception
          raise ActiveRecord::DeleteRestrictionError.new(reflection.name) unless empty?

        when :restrict_with_error
          unless empty?
            record = owner.class.human_attribute_name(reflection.name).downcase
            owner.errors.add(:base, :"restrict_dependent_destroy.has_many", record: record)
            throw(:abort)
          end

        when :destroy
          # No point in executing the counter update since we're going to destroy the parent anyway
          load_target.each { |t| t.destroyed_by_association = reflection }
          destroy_all
        when :destroy_async
          load_target.each do |t|
            t.destroyed_by_association = reflection
          end

          unless target.empty?
            association_class = target.first.class
            if association_class.query_constraints_list
              primary_key_column = association_class.query_constraints_list.map(&:to_sym)
              ids = target.collect { |assoc| primary_key_column.map { |col| assoc.public_send(col) } }
            else
              primary_key_column = association_class.primary_key.to_sym
              ids = target.collect { |assoc| assoc.public_send(primary_key_column) }
            end

            ids.each_slice(owner.class.destroy_association_async_batch_size || ids.size) do |ids_batch|
              enqueue_destroy_association(
                owner_model_name: owner.class.to_s,
                owner_id: owner.id,
                association_class: reflection.klass.to_s,
                association_ids: ids_batch,
                association_primary_key_column: primary_key_column,
                ensuring_owner_was_method: options.fetch(:ensuring_owner_was, nil)
              )
            end
          end
        else
          delete_all
        end
      end
    end
  end
end
