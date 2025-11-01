class Api::V1::WishlistItemsController < ApplicationController
  before_action :set_wishlist

  # GET /api/v1/wishlist
  def index
    @wishlist_items = @wishlist.wishlist_items.includes(product_variant: { product: [:brand, :category, :product_images] })
    render_success(format_wishlist_data(@wishlist_items), 'Wishlist retrieved successfully')
  end

  # POST /api/v1/wishlist/items
  def create
    @wishlist_item = @wishlist.wishlist_items.find_or_initialize_by(
      product_variant_id: params[:product_variant_id]
    )
    
    if @wishlist_item.persisted?
      render_success(format_wishlist_data(@wishlist.wishlist_items), 'Item already in wishlist')
    elsif @wishlist_item.save
      render_created(format_wishlist_data(@wishlist.wishlist_items), 'Item added to wishlist successfully')
    else
      render_validation_errors(@wishlist_item.errors.full_messages, 'Failed to add item to wishlist')
    end
  end

  # DELETE /api/v1/wishlist/items/:id
  def destroy
    @wishlist_item = @wishlist.wishlist_items.find_by(id: params[:id])
    
    if @wishlist_item
      @wishlist_item.destroy
      render_success(format_wishlist_data(@wishlist.wishlist_items), 'Item removed from wishlist successfully')
    else
      render_not_found('Wishlist item not found')
    end
  end

  private

  def set_wishlist
    @wishlist = current_user.wishlist || current_user.create_wishlist
  end

  def format_wishlist_data(items)
    items.map do |item|
      variant = item.product_variant
      product = variant.product
      {
        wishlist_item_id: item.id,
        product_variant: {
          variant_id: variant.id,
          sku: variant.sku,
          price: variant.price,
          discounted_price: variant.discounted_price,
          stock_quantity: variant.stock_quantity,
          product_name: product.name,
          product_id: product.id,
          brand_name: product.brand.name,
          category_name: product.category.name,
          image_url: variant.product_images.first&.image_url || product.product_variants.first&.product_images&.first&.image_url
        }
      }
    end
  end
end
