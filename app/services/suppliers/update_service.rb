# frozen_string_literal: true

# Service for updating supplier and profile
module Suppliers
  class UpdateService < BaseService
    attr_reader :supplier

    def initialize(supplier, supplier_params)
      super()
      @supplier = supplier
      @supplier_params = supplier_params.dup
      @profile_params = @supplier_params.delete(:supplier_profile_attributes)
    end

    def call
      update_supplier
      update_profile if @profile_params.present?
      set_result(@supplier)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def update_supplier
      unless @supplier.update(@supplier_params)
        add_errors(@supplier.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @supplier
      end
    end

    def update_profile
      profile = @supplier.primary_supplier_profile || @supplier.supplier_profile
      
      if profile
        unless profile.update(@profile_params)
          add_errors(profile.errors.full_messages)
          raise ActiveRecord::RecordInvalid, profile
        end
      else
        profile = @supplier.create_supplier_profile(@profile_params)
        profile.update(owner_id: @supplier.id, user_id: @supplier.id)
      end
    end
  end
end

