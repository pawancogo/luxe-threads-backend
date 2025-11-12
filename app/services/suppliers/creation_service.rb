# frozen_string_literal: true

# Service for creating Supplier records from User signup
# Automatically creates a Supplier record when a User signs up with role 'supplier'
module Suppliers
  class CreationService
    attr_reader :user, :supplier, :errors

    def initialize(user)
      @user = user
      @errors = []
    end

    def call
      return nil unless should_create?

      ActiveRecord::Base.transaction do
        create_supplier
        create_supplier_profile if @supplier&.persisted?
      end

      @supplier
    rescue StandardError => e
      @errors << e.message
      Rails.logger.error "Suppliers::CreationService failed for user #{@user.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end

    def success?
      @supplier&.persisted? && @errors.empty?
    end

    private

    def should_create?
      @user&.role == 'supplier' && @user.persisted?
    end

    def create_supplier
      # Check if supplier already exists with this email
      existing_supplier = Supplier.find_by(email: @user.email)
      
      if existing_supplier
        @supplier = existing_supplier
        Rails.logger.info "Supplier already exists for email #{@user.email}"
        return
      end

      @supplier = Supplier.new(supplier_attributes)
      unless @supplier.save
        @errors.concat(@supplier.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @supplier
      end
    end

    def supplier_attributes
      {
        first_name: @user.first_name,
        last_name: @user.last_name,
        email: @user.email,
        phone_number: @user.phone_number,
        password_digest: @user.password_digest, # Share the same password
        role: 'basic_supplier', # Default role
        email_verified: @user.email_verified,
        temp_password_digest: @user.temp_password_digest,
        temp_password_expires_at: @user.temp_password_expires_at,
        password_reset_required: @user.password_reset_required
      }
    end

    def create_supplier_profile
      # Only create if user already has a supplier_profile
      return unless @user.supplier_profile.present?
      return if @supplier.supplier_profile.present? # Already has one

      user_profile = @user.supplier_profile
      
      # Generate a unique GST number for the supplier
      # Since GST numbers must be unique, we can't copy the user's GST number
      unique_gst = generate_unique_gst_number
      
      # Create supplier profile with same data as user's supplier_profile
      # But with a unique GST number
      supplier_profile = @supplier.build_supplier_profile(
        company_name: user_profile.company_name,
        gst_number: unique_gst,
        description: user_profile.description,
        website_url: user_profile.website_url,
        verified: user_profile.verified
      )
      
      unless supplier_profile.save
        @errors.concat(supplier_profile.errors.full_messages)
        Rails.logger.error "Failed to create supplier profile for supplier #{@supplier.id}"
      end
    end

    def generate_unique_gst_number
      loop do
        gst = "GST#{@supplier.id}#{Time.now.to_i.to_s.last(6)}"
        break gst unless SupplierProfile.exists?(gst_number: gst)
      end
    end
  end
end

