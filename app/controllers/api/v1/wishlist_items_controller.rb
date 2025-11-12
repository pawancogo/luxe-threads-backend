# frozen_string_literal: true

# Refactored WishlistItemsController using Clean Architecture
# Controller → Service → Model → Serializer
class Api::V1::WishlistItemsController < ApplicationController
  include CustomerOnly
  
  before_action :set_wishlist

  # GET /api/v1/wishlist
  def index
    wishlist = Wishlist.with_items.find(@wishlist.id)
    serializer_options = { include_product_details: true }
    render_success(
      WishlistSerializer.new(wishlist, serializer_options).as_json,
      'Wishlist retrieved successfully'
    )
  end

  # POST /api/v1/wishlist/items
  def create
      service = Wishlists::ItemCreationService.new(
      @wishlist,
      params[:product_variant_id]
    )
    service.call
    
    if service.success?
      wishlist = Wishlist.with_items.find(@wishlist.id)
      serializer_options = { include_product_details: true }
      
      if service.wishlist_item.persisted? && service.wishlist_item.previous_changes.empty?
        # Item already existed
        render_success(
          WishlistSerializer.new(wishlist, serializer_options).as_json,
          'Item already in wishlist'
        )
      else
        render_created(
          WishlistSerializer.new(wishlist, serializer_options).as_json,
          'Item added to wishlist successfully'
        )
      end
    else
      render_validation_errors(service.errors, 'Failed to add item to wishlist')
    end
  end

  # DELETE /api/v1/wishlist/items/:id
  def destroy
    @wishlist_item = @wishlist.wishlist_items.find_by(id: params[:id])
    
    unless @wishlist_item
      render_not_found('Wishlist item not found')
      return
    end
    
    service = Wishlists::ItemDeletionService.new(@wishlist_item)
    service.call
    
    if service.success?
      wishlist = Wishlist.with_items.find(@wishlist.id)
      serializer_options = { include_product_details: true }
      render_success(
        WishlistSerializer.new(wishlist, serializer_options).as_json,
        'Item removed from wishlist successfully'
      )
    else
      render_validation_errors(service.errors, 'Failed to remove item from wishlist')
    end
  end

  private

  def set_wishlist
    @wishlist = current_user.wishlist || current_user.create_wishlist
  end
end
