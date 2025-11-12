# frozen_string_literal: true

# Concern for models that need to ensure only one default record per scope
# Usage: ensure_single_default(:is_default, scope: :user_id)
module SingleDefaultable
  extend ActiveSupport::Concern

  module ClassMethods
    # Configure single default behavior
    # Usage: ensure_single_default_for :is_default, scope: :user_id
    def ensure_single_default_for(field_name, scope: nil)
      callback_name = "ensure_single_#{field_name}"
      
      before_save callback_name.to_sym, if: -> { will_save_change_to?(field_name) }
      
      define_method(callback_name) do
        return unless public_send(field_name)
        
        query = self.class.where.not(id: id || 0)
        query = query.where(scope => public_send(scope)) if scope
        query = query.where(field_name => true)
        query.update_all(field_name => false)
      end
    end
  end
end

