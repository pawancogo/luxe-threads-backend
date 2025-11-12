# frozen_string_literal: true

# Service for creating orders
# Encapsulates order creation business logic
module Orders
  class CreationService < BaseService
    attr_reader :order

    def initialize(user, cart, order_params)
      super()
      @user = user
      @cart = cart
      @order_params = order_params
      @coupon_code = order_params[:coupon_code]&.strip&.upcase
    end

    def call
      validate_cart!
      calculate_totals
      create_order
      apply_coupon if @coupon_code.present?
      transfer_cart_items
      clear_cart
      send_confirmation_email
      set_result(@order)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def validate_cart!
      if @cart.cart_items.empty?
        add_error('Cart is empty')
        raise StandardError, 'Cart is empty'
      end
    end

    def calculate_totals
      @subtotal = calculate_subtotal
      @coupon_discount = 0.0
      @total = @subtotal
    end

    def calculate_subtotal
      @cart.cart_items.includes(:product_variant).sum do |item|
        variant = item.product_variant
        price = variant.discounted_price || variant.price
        price * item.quantity
      end
    end

    def create_order
      order_attributes = @order_params.except(:payment_method_id, :coupon_code).merge(
        user: @user,
        status: 'pending',
        payment_status: 'pending',
        subtotal: @subtotal,
        coupon_discount: @coupon_discount,
        total_amount: @total,
        currency: 'INR'
      )

      @order = Order.create!(order_attributes)
    end

    def apply_coupon
      coupon = Coupon.find_by(code: @coupon_code)
      return unless coupon&.available?

      # Validate coupon for user
      user_validation = Coupons::UserValidationService.new(coupon, @user)
      user_validation.call
      return unless user_validation.success?

      # Validate minimum order amount
      if coupon.min_order_amount.present? && @subtotal < coupon.min_order_amount
        add_error("Minimum order amount is ₹#{coupon.min_order_amount}")
        return
      end

      # Calculate discount using service
      discount_service = Coupons::DiscountCalculationService.new(coupon, @subtotal)
      discount_service.call
      
      unless discount_service.success?
        add_errors(discount_service.errors)
        return
      end

      @coupon_discount = discount_service.discount_amount.to_f
      @total = @subtotal - @coupon_discount
      
      @order.update!(
        coupon_discount: @coupon_discount,
        total_amount: @total
      )

      coupon_usage = CouponUsage.create!(
        coupon: coupon,
        user: @user,
        order: @order,
        discount_amount: @coupon_discount,
        order_amount: @subtotal
      )
      
      # Track coupon usage and increment usage count
      tracking_service = CouponUsageTrackingService.new(coupon_usage)
      tracking_service.call
      
      unless tracking_service.success?
        add_errors(tracking_service.errors)
        raise StandardError, 'Failed to track coupon usage'
      end
    end

    def transfer_cart_items
      cart_items = @cart.cart_items.includes(
        product_variant: [:product, :product_images, :product_variant_attributes]
      )

      cart_items.each do |cart_item|
        variant = cart_item.product_variant
        product = variant.product

        validate_stock!(variant, cart_item.quantity)

        final_price = variant.discounted_price || variant.price
        
        order_item = @order.order_items.create!(
          product_variant_id: variant.id,
          supplier_profile_id: product.supplier_profile_id,
          quantity: cart_item.quantity,
          price_at_purchase: final_price,
          discounted_price: variant.discounted_price,
          final_price: final_price,
          product_name: product.name,
          product_image_url: variant.product_images.first&.image_url,
          product_variant_attributes: format_variant_attributes(variant),
          fulfillment_status: 'pending',
          currency: variant.currency || 'INR',
          is_returnable: true,
          return_deadline: calculate_return_deadline
        )

        update_inventory(variant, cart_item.quantity)
      end
    end

    def validate_stock!(variant, quantity)
      available_qty = variant.available_quantity || 
                      (variant.stock_quantity || 0) - (variant.reserved_quantity || 0)
      
      if available_qty < quantity
        add_error("Insufficient stock for #{variant.sku}. Available: #{available_qty}, Requested: #{quantity}")
        raise StandardError, "Insufficient stock for #{variant.sku}"
      end
    end

    def update_inventory(variant, quantity)
      variant.decrement!(:stock_quantity, quantity)
      variant.increment!(:reserved_quantity, quantity)
      # Update availability flags - callback will handle it via before_save
      # But we ensure flags are updated by calling service
      if variant.respond_to?(:update_availability_flags)
        availability_service = Products::VariantAvailabilityService.new(variant)
        availability_service.call
      end
    end

    def format_variant_attributes(variant)
      variant.product_variant_attributes.map do |pva|
        {
          attribute_type: pva.attribute_value.attribute_type.name,
          attribute_value: pva.attribute_value.value
        }
      end.to_json
    end

    def clear_cart
      @cart.cart_items.destroy_all
    end

    def send_confirmation_email
      Orders::EmailService.send_confirmation(@order)
    end

    def calculate_return_deadline
      @order.created_at.to_date + 30.days
    end
  end
end

