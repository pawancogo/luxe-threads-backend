class Api::V1::WishlistItemsController < ApplicationController
  include ApiFormatters
  include CustomerOnly
  
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
    items.map { |item| format_wishlist_item_data(item) }
  end
end
