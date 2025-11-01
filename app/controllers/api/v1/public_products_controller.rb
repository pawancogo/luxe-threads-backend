class Api::V1::PublicProductsController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show]

  # GET /api/v1/public/products - Public product listing (for customers)
  def index
    @products = Product.active.includes(:brand, :category, product_variants: [:product_images])
                      .page(params[:page] || 1)
                      .per(params[:per_page] || 20)
    
    render_success(format_public_products_data(@products), 'Products retrieved successfully')
  end

  # GET /api/v1/public/products/:id - Public product details (for customers)
  def show
    @product = Product.active.includes(
      :brand, 
      :category, 
      :supplier_profile,
      product_variants: [
        :product_images, 
        :product_variant_attributes,
        attribute_values: :attribute_type
      ],
      reviews: :user
    ).find(params[:id])
    
    render_success(format_public_product_detail_data(@product), 'Product retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Product not found')
  end

  private

  def format_public_products_data(products)
    products.map do |product|
      variant = product.product_variants.first
      {
        id: product.id,
        name: product.name,
        description: product.description&.truncate(200),
        brand_name: product.brand.name,
        category_name: product.category.name,
        supplier_name: product.supplier_profile.company_name,
        price: variant&.price,
        discounted_price: variant&.discounted_price,
        image_url: variant&.product_images&.first&.image_url || product.product_variants.first&.product_images&.first&.image_url,
        stock_available: product.product_variants.any? { |v| v.stock_quantity > 0 },
        average_rating: product.reviews.average(:rating)&.round(1)
      }
    end
  end

  def format_public_product_detail_data(product)
    {
      id: product.id,
      name: product.name,
      description: product.description,
      brand: {
        id: product.brand.id,
        name: product.brand.name,
        logo_url: product.brand.logo_url
      },
      category: {
        id: product.category.id,
        name: product.category.name
      },
      supplier: {
        id: product.supplier_profile.id,
        company_name: product.supplier_profile.company_name,
        verified: product.supplier_profile.verified
      },
      variants: product.product_variants.map do |variant|
        {
          id: variant.id,
          sku: variant.sku,
          price: variant.price,
          discounted_price: variant.discounted_price,
          stock_quantity: variant.stock_quantity,
          weight_kg: variant.weight_kg,
          images: variant.product_images.order(:display_order).map do |image|
            {
              id: image.id,
              url: image.image_url,
              alt_text: image.alt_text
            }
          end,
          attributes: variant.product_variant_attributes.map do |pva|
            {
              attribute_type: pva.attribute_value.attribute_type.name,
              attribute_value: pva.attribute_value.value
            }
          end
        }
      end,
      reviews: product.reviews.order(created_at: :desc).limit(10).map do |review|
        {
          id: review.id,
          user_name: review.user.full_name,
          rating: review.rating,
          comment: review.comment,
          verified_purchase: review.verified_purchase,
          created_at: review.created_at.iso8601
        }
      end,
      average_rating: product.reviews.average(:rating)&.round(1),
      total_reviews: product.reviews.count
    }
  end
end
