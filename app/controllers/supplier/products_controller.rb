class Supplier::ProductsController < ApplicationController
    before_action :authenticate_supplier!
  
    def create
      @product = current_user.supplier_profile.products.build(product_params)
  
      if @product.save
        render json: @product, status: :created
      else
        render json: @product.errors, status: :unprocessable_entity
      end
    end
  
    private
  
    def product_params
      params.require(:product).permit(
        :name,
        :description,
        :category_id,
        :brand_id,
        product_variants_attributes: [
          :sku,
          :price,
          :discounted_price,
          :stock_quantity,
          :weight_kg,
          product_images_attributes: [
            :image_url,
            :alt_text,
            :display_order,
            :_destroy
          ],
          attribute_values: [
            :attribute_type,
            :value
          ]
        ]
      )
    end
  
    def authenticate_supplier!
      # Implement your authentication logic here, e.g., using Devise
      # For now, we'll assume a `current_user` method is available
      head :unauthorized unless current_user&.supplier?
    end
  end