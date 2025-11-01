class Api::V1::CartItemsController < ApplicationController
  before_action :set_cart

  def create
    # Find item if it already exists to update quantity
    @cart_item = @cart.cart_items.find_or_initialize_by(product_variant_id: params[:product_variant_id])
    @cart_item.quantity = (@cart_item.quantity || 0) + params[:quantity].to_i
    
    if @cart_item.save
      @cart_items = @cart.cart_items.includes(product_variant: { product: [:brand, :category, product_variants: :product_images] })
      total_price = @cart_items.sum { |item| (item.product_variant.discounted_price || item.product_variant.price) * item.quantity }
      render_created(format_cart_response(@cart_items, total_price), 'Item added to cart successfully')
    else
      render_validation_errors(@cart_item.errors.full_messages, 'Failed to add item to cart')
    end
  end

  def update
    @cart_item = @cart.cart_items.find(params[:id])
    if @cart_item.update(quantity: params[:quantity].to_i)
      @cart_items = @cart.cart_items.includes(product_variant: { product: [:brand, :category, product_variants: :product_images] })
      total_price = @cart_items.sum { |item| (item.product_variant.discounted_price || item.product_variant.price) * item.quantity }
      render_success(format_cart_response(@cart_items, total_price), 'Cart item updated successfully')
    else
      render_validation_errors(@cart_item.errors.full_messages, 'Failed to update cart item')
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    @cart_item.destroy
    @cart_items = @cart.cart_items.includes(product_variant: { product: [:brand, :category, product_variants: :product_images] })
    total_price = @cart_items.sum { |item| (item.product_variant.discounted_price || item.product_variant.price) * item.quantity }
    render_success(format_cart_response(@cart_items, total_price), 'Item removed from cart successfully')
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def format_cart_response(cart_items, total_price)
    {
      cart_items: cart_items.map do |item|
        variant = item.product_variant
        product = variant.product
        {
          cart_item_id: item.id,
          quantity: item.quantity,
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
          },
          subtotal: (variant.discounted_price || variant.price) * item.quantity
        }
      end,
      total_price: total_price,
      item_count: cart_items.sum(&:quantity)
    }
  end
end