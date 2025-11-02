# frozen_string_literal: true

# Service for creating products with variants
# Orchestrates product and variant creation
class ProductCreationService
  attr_reader :product, :errors

  def initialize(supplier_profile, product_params)
    @supplier_profile = supplier_profile
    @product_params = product_params
    @variants_params = product_params.delete(:variants_attributes) || []
    @errors = []
  end

  def call
    ActiveRecord::Base.transaction do
      create_product
      create_variants if success?
    end

    self
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error "ProductCreationService failed: #{e.message}"
    self
  end

  def success?
    @product&.persisted? && @errors.empty?
  end

  private

  def create_product
    # Merge variants into product params
    product_form_params = @product_params.merge(
      supplier_profile_id: @supplier_profile.id
    )
    
    # Add variants if present
    product_form_params[:variants_attributes] = @variants_params if @variants_params.present?
    
    form = ProductForm.new(product_form_params)

    unless form.save
      @errors.concat(form.errors.full_messages)
      raise ActiveRecord::RecordInvalid, form.product
    end

    @product = form.product
  end

  def create_variants
    # Variants are created by ProductForm
    # Additional variant processing can be added here if needed
  end
end

