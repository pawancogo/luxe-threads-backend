# frozen_string_literal: true

# ============================================================================
# CODE STYLE GUIDE - Practical Examples for New Developers
# ============================================================================
# 
# This file demonstrates HOW to write code following SOLID, KISS, DRY, YAGNI
# principles in our Rails backend. Use these patterns as reference.
#
# Architecture: Controllers → Services → Models (+ Concerns) → Serializers/Presenters
# ============================================================================

# ============================================================================
# 1. CONTROLLERS - Thin Layer (Handle HTTP, Delegate to Services)
# ============================================================================

# ✅ GOOD: Thin controller that delegates to services
# Location: app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  include ServiceResponseHandler  # DRY: Reusable response handling
  
  before_action :set_order, only: [:show, :cancel]
  
  def create
    # Delegate business logic to service
    service = Orders::CreationService.new(
      current_user,
      current_user.cart,
      order_params
    )
    
    service.call
    handle_service_response(
      service,
      success_message: 'Order created successfully',
      error_message: 'Order creation failed',
      presenter: OrderSerializer,
      status: :created
    )
  end
  
  def show
    # Use model scopes for queries (KISS - no repository layer)
    @order = Order.with_full_details.find(params[:id])
    
    # Use serializer for response formatting
    render_success(
      OrderSerializer.new(@order, serializer_options).as_json,
      'Order retrieved successfully'
    )
  end
  
  private
  
  def order_params
    params.require(:order).permit(
      :shipping_address_id,
      :billing_address_id,
      :coupon_code
    )
  end
end

# ❌ BAD: Fat controller with business logic
class Api::V1::OrdersController < ApplicationController
  def create
    # ❌ Business logic in controller
    cart = current_user.cart
    return render_error('Cart is empty') if cart.cart_items.empty?
    
    # ❌ Direct model manipulation
    order = Order.new(user: current_user)
    order.total_amount = cart.total_amount
    
    # ❌ Complex logic in controller
    if params[:coupon_code].present?
      coupon = Coupon.find_by(code: params[:coupon_code])
      if coupon && coupon.valid_for_user?(current_user)
        discount = coupon.calculate_discount(order.total_amount)
        order.coupon_discount = discount
      end
    end
    
    # ❌ Email sending in controller
    if order.save
      OrderMailer.order_confirmation(order).deliver_now
      render_success(order)
    else
      render_error(order.errors)
    end
  end
end


# ============================================================================
# 2. SERVICES - Business Logic Layer
# ============================================================================

# ✅ GOOD: Service encapsulates business workflow
# Location: app/services/orders/creation_service.rb
module Orders
  class CreationService < BaseService
    attr_reader :order
    
    def initialize(user, cart, params = {})
      super()
      @user = user
      @cart = cart
      @params = params
    end
    
    def call
      with_transaction do
        validate_cart!
        create_order
        transfer_cart_items
        apply_coupon if @params[:coupon_code].present?
        calculate_totals
        send_confirmation_email
      end
      
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
        raise StandardError, 'Cannot create order with empty cart'
      end
    end
    
    def create_order
      @order = Order.new(
        user: @user,
        shipping_address_id: @params[:shipping_address_id],
        billing_address_id: @params[:billing_address_id],
        status: 'pending'
      )
      
      unless @order.save
        add_errors(@order.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @order
      end
    end
    
    def transfer_cart_items
      @cart.cart_items.each do |cart_item|
        OrderItem.create!(
          order: @order,
          product_variant: cart_item.product_variant,
          quantity: cart_item.quantity,
          price: cart_item.product_variant.price
        )
      end
    end
    
    def apply_coupon
      coupon_service = Coupons::ApplicationService.new(
        @params[:coupon_code],
        @order.subtotal,
        @user
      )
      coupon_service.call
      
      unless coupon_service.success?
        add_errors(coupon_service.errors)
        return
      end
      
      @order.update!(
        coupon_id: coupon_service.coupon.id,
        coupon_discount: coupon_service.discount_amount
      )
    end
    
    def calculate_totals
      @order.reload
      @order.update!(
        subtotal: @order.order_items.sum(&:total_price),
        tax_amount: calculate_tax,
        total_amount: calculate_total
      )
    end
    
    def send_confirmation_email
      Orders::EmailService.send_confirmation(@order)
    end
    
    def calculate_tax
      # Tax calculation logic
      (@order.subtotal * 0.18).round(2)
    end
    
    def calculate_total
      @order.subtotal + @order.tax_amount - (@order.coupon_discount || 0)
    end
  end
end

# ✅ GOOD: Simple service for single responsibility
# Location: app/services/support/assignment_service.rb
module Support
  class AssignmentService < BaseService
    def initialize(support_ticket, admin)
      super()
      @support_ticket = support_ticket
      @admin = admin
    end
    
    def call
      with_transaction do
        assign_ticket
      end
      set_result(@support_ticket)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end
    
    private
    
    def assign_ticket
      unless @support_ticket.update(
        assigned_to: @admin,
        assigned_at: Time.current,
        status: 'in_progress'
      )
        add_errors(@support_ticket.errors.full_messages)
        raise ActiveRecord::RecordInvalid, @support_ticket
      end
    end
  end
end

# ❌ BAD: Service doing too much (violates Single Responsibility)
module Orders
  class CreationService < BaseService
    def call
      # ❌ Creating order
      create_order
      
      # ❌ Sending emails
      send_emails
      
      # ❌ Updating inventory
      update_inventory
      
      # ❌ Generating PDFs
      generate_invoice_pdf
      
      # ❌ Calling external APIs
      notify_shipping_provider
      
      # ❌ Too many responsibilities!
    end
  end
end


# ============================================================================
# 3. MODELS - Data Schema, Validations, Scopes, Associations
# ============================================================================

# ✅ GOOD: Slim model with scopes (no business logic)
# Location: app/models/order.rb
class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :order_items, dependent: :destroy
  belongs_to :shipping_address, class_name: 'Address'
  belongs_to :billing_address, class_name: 'Address'
  
  # Validations
  validates :status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  
  # Enums
  enum status: {
    pending: 'pending',
    confirmed: 'confirmed',
    processing: 'processing',
    shipped: 'shipped',
    delivered: 'delivered',
    cancelled: 'cancelled'
  }
  
  # Scopes (KISS - use ActiveRecord scopes, not repository layer)
  scope :for_customer, ->(customer) { where(user: customer) }
  scope :with_full_details, -> {
    includes(:user, :order_items, :shipping_address, :billing_address)
  }
  scope :pending_payment, -> { where(status: 'pending', payment_status: 'pending') }
  scope :recent, -> { order(created_at: :desc) }
  
  # Include concerns for reusable logic (DRY)
  include StatusTrackable  # For status history tracking
  
  # Simple helper methods (not business logic)
  def order_number
    self[:order_number] || id.to_s.rjust(8, '0')
  end
  
  def can_be_cancelled?
    ['pending', 'confirmed'].include?(status)
  end
end

# ❌ BAD: Fat model with business logic
class Order < ApplicationRecord
  # ❌ Business logic in model
  def apply_coupon(coupon_code)
    coupon = Coupon.find_by(code: coupon_code)
    return false unless coupon
    
    if coupon.valid_for_user?(user)
      discount = coupon.calculate_discount(total_amount)
      update(coupon_discount: discount)
      send_coupon_email
      true
    else
      false
    end
  end
  
  # ❌ Email sending in model
  def send_confirmation_email
    OrderMailer.order_confirmation(self).deliver_now
  end
  
  # ❌ Complex calculations in model
  def calculate_totals
    # 50 lines of calculation logic...
  end
end


# ============================================================================
# 4. CONCERNS - Reusable Model Logic (DRY)
# ============================================================================

# ✅ GOOD: Concern for reusable functionality
# Location: app/models/concerns/status_trackable.rb
module StatusTrackable
  extend ActiveSupport::Concern
  
  included do
    # Add status_history JSON column in migration
    # serialize :status_history, Array (if using text column)
  end
  
  # Track status changes
  def track_status_change(new_status, changed_by: nil)
    history = status_history_array
    history << {
      status: new_status,
      changed_at: Time.current.iso8601,
      changed_by: changed_by&.id
    }
    update_column(:status_history, history.to_json)
  end
  
  def status_history_array
    return [] if status_history.blank?
    JSON.parse(status_history) rescue []
  end
  
  def last_status_change
    status_history_array.last
  end
end

# Usage in model:
# class Order < ApplicationRecord
#   include StatusTrackable
# end

# ✅ GOOD: Concern for price aggregation
# Location: app/models/concerns/price_aggregatable.rb
module PriceAggregatable
  extend ActiveSupport::Concern
  
  included do
    # Configure in model: price_aggregatable_on :product_variants
  end
  
  class_methods do
    def price_aggregatable_on(association_name, price_columns: [:price, :discounted_price])
      @price_association = association_name
      @price_columns = price_columns
    end
  end
  
  def update_aggregated_prices
    # Aggregate prices from variants
    association_name = self.class.price_association
    variants = public_send(association_name)
    
    self.class.price_columns.each do |column|
      values = variants.pluck(column).compact
      base_column = "base_#{column}"
      if respond_to?("#{base_column}=")
        public_send("#{base_column}=", values.min)
      end
    end
  end
end

# Usage:
# class Product < ApplicationRecord
#   include PriceAggregatable
#   price_aggregatable_on :product_variants
# end


# ============================================================================
# 5. SERIALIZERS - API Response Formatting
# ============================================================================

# ✅ GOOD: Serializer for API responses
# Location: app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  # Define attributes to include
  attributes :id, :status, :payment_status, :total_amount, :currency
  
  # Define associations (options passed through automatically)
  has_one :shipping_address, serializer: AddressSerializer
  has_one :billing_address, serializer: AddressSerializer
  has_many :order_items, serializer: OrderItemSerializer
  
  # Conditional associations
  has_one :user, serializer: UserSerializer, if: :user_loaded?
  
  def attributes(*args)
    result = super
    # Add computed attributes
    result[:order_number] = order_number
    result[:formatted_total] = format_currency(object.total_amount)
    result[:created_at] = format_date(object.created_at)
    
    # Use options for conditional data
    result[:payments] = serialize_payments if options[:include_payments]
    
    result
  end
  
  private
  
  def order_number
    object.order_number || object.id.to_s.rjust(8, '0')
  end
  
  def format_currency(amount, currency = 'INR')
    case currency
    when 'INR' then "₹#{amount.to_f.round(2)}"
    when 'USD' then "$#{amount.to_f.round(2)}"
    else "#{amount.to_f.round(2)} #{currency}"
    end
  end
  
  def format_date(date)
    date&.iso8601
  end
  
  def user_loaded?
    options[:include_user] || object.association(:user).loaded?
  end
  
  def serialize_payments
    return [] unless object.respond_to?(:payments)
    PaymentSerializer.collection(object.payments, options)
  end
end

# Usage in controller:
# OrderSerializer.new(order, include_payments: true).as_json


# ============================================================================
# 6. PRESENTERS - Admin View Formatting
# ============================================================================

# ✅ GOOD: Presenter for admin views
# Location: app/presenters/order_presenter.rb
class OrderPresenter
  attr_reader :order
  
  delegate :id, :order_number, :status, :total_amount, to: :order
  
  def initialize(order)
    @order = order
  end
  
  # Status formatting for views
  def status_label
    {
      'pending' => 'Pending',
      'confirmed' => 'Confirmed',
      'shipped' => 'Shipped',
      'delivered' => 'Delivered',
      'cancelled' => 'Cancelled'
    }[order.status.to_s] || order.status.to_s.humanize
  end
  
  def status_badge_class
    {
      'pending' => 'badge-warning',
      'confirmed' => 'badge-info',
      'shipped' => 'badge-primary',
      'delivered' => 'badge-success',
      'cancelled' => 'badge-danger'
    }[order.status.to_s] || 'badge-secondary'
  end
  
  # Customer info
  def customer_name
    order.user&.full_name || 'Unknown Customer'
  end
  
  # Financial formatting
  def formatted_total
    format_currency(order.total_amount, order.currency)
  end
  
  private
  
  def format_currency(amount, currency = 'INR')
    case currency
    when 'INR' then "₹#{amount.to_f.round(2)}"
    when 'USD' then "$#{amount.to_f.round(2)}"
    else "#{amount.to_f.round(2)} #{currency}"
    end
  end
end

# Usage in admin controller:
# @order_presenter = OrderPresenter.new(@order)
# In view: <%= @order_presenter.status_label %>


# ============================================================================
# 7. DECISION TREE - When to Use What?
# ============================================================================

# Q: Where should this code go?
#
# ┌─────────────────────────────────────────────────────────────┐
# │ Is it HTTP request handling?                                │
# │ → YES: Controller                                           │
# │ → NO: Continue...                                           │
# └─────────────────────────────────────────────────────────────┘
#                          │
#                          ▼
# ┌─────────────────────────────────────────────────────────────┐
# │ Is it business logic/workflow?                              │
# │ → YES: Service Object                                       │
# │ → NO: Continue...                                           │
# └─────────────────────────────────────────────────────────────┘
#                          │
#                          ▼
# ┌─────────────────────────────────────────────────────────────┐
# │ Is it reusable across multiple models?                      │
# │ → YES: Concern (app/models/concerns/)                       │
# │ → NO: Continue...                                           │
# └─────────────────────────────────────────────────────────────┘
#                          │
#                          ▼
# ┌─────────────────────────────────────────────────────────────┐
# │ Is it data query/filtering?                                 │
# │ → YES: Model Scope                                          │
# │ → NO: Continue...                                           │
# └─────────────────────────────────────────────────────────────┘
#                          │
#                          ▼
# ┌─────────────────────────────────────────────────────────────┐
# │ Is it API response formatting?                              │
# │ → YES: Serializer                                           │
# │ → NO: Continue...                                           │
# └─────────────────────────────────────────────────────────────┘
#                          │
#                          ▼
# ┌─────────────────────────────────────────────────────────────┐
# │ Is it admin view formatting?                                │
# │ → YES: Presenter                                            │
# │ → NO: Model (validations, associations, simple helpers)      │
# └─────────────────────────────────────────────────────────────┘


# ============================================================================
# 8. COMMON PATTERNS & BEST PRACTICES
# ============================================================================

# ✅ Pattern: Service with transaction
module Orders
  class CancellationService < BaseService
    def call
      with_transaction do
        validate_cancellation!
        cancel_order
        refund_payment
        send_notification
      end
      set_result(@order)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end
  end
end

# ✅ Pattern: Service composition (one service calls another)
module Orders
  class CreationService < BaseService
    def apply_coupon
      # Delegate to specialized service
      coupon_service = Coupons::ApplicationService.new(
        @params[:coupon_code],
        @order.subtotal,
        @user
      )
      coupon_service.call
      
      unless coupon_service.success?
        add_errors(coupon_service.errors)
        return
      end
      
      # Use result from composed service
      @order.update!(
        coupon_id: coupon_service.coupon.id,
        coupon_discount: coupon_service.discount_amount
      )
    end
  end
end

# ✅ Pattern: Model scope for queries (KISS - no repository)
class Order < ApplicationRecord
  # Simple scope
  scope :recent, -> { order(created_at: :desc) }
  
  # Scope with parameter
  scope :for_customer, ->(customer) { where(user: customer) }
  
  # Scope with eager loading
  scope :with_full_details, -> {
    includes(:user, :order_items, :shipping_address, :billing_address)
  }
  
  # Complex scope (still simple, no business logic)
  scope :pending_payment, -> {
    where(status: 'pending', payment_status: 'pending')
      .where('created_at > ?', 7.days.ago)
  }
end

# ✅ Pattern: Error handling in services
module Orders
  class CreationService < BaseService
    def call
      validate_cart!
      create_order
      # ... rest of logic
    rescue StandardError => e
      handle_error(e)  # Adds to @errors, logs error
      self
    end
    
    private
    
    def validate_cart!
      if @cart.cart_items.empty?
        add_error('Cart is empty')
        raise StandardError, 'Validation failed'
      end
    end
  end
end

# ✅ Pattern: Controller response handling (DRY)
class Api::V1::OrdersController < ApplicationController
  include ServiceResponseHandler
  
  def create
    service = Orders::CreationService.new(current_user, cart, params)
    service.call
    
    handle_service_response(
      service,
      success_message: 'Order created',
      error_message: 'Failed to create order',
      presenter: OrderSerializer,
      status: :created
    )
  end
end


# ============================================================================
# 8.5. CONSISTENT BUSINESS LOGIC ACROSS ALL ENTRY POINTS
# ============================================================================
#
# PROBLEM: Services are used at controller level only. When data is updated
# through Rails Admin or admin views directly, service validations and effects
# won't be triggered, leading to inconsistent behavior.
#
# SOLUTION: Use a layered approach to ensure business logic runs regardless
# of entry point (API, Rails Admin, or Admin Views).
#
# ============================================================================

# ✅ GOOD: Model-level validations and callbacks for data integrity
# These ALWAYS run, regardless of entry point
# Location: app/models/order.rb
class Order < ApplicationRecord
  # Data integrity validations (always run)
  validates :status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validate :shipping_address_required, if: :requires_shipping?
  
  # Business logic callbacks (always run)
  after_create :generate_order_number
  after_update :update_inventory_on_status_change, if: :saved_change_to_status?
  after_update :send_status_notification, if: :saved_change_to_status?
  
  # Side effects that should always happen (model level)
  after_save :update_product_stock_counts, if: :saved_change_to_status?
  
  private
  
  def generate_order_number
    update_column(:order_number, "ORD-#{id.to_s.rjust(8, '0')}") if order_number.blank?
  end
  
  def update_inventory_on_status_change
    # This runs whether updated via API, Rails Admin, or Admin View
    if status == 'cancelled' && status_before_last_save == 'confirmed'
      order_items.each do |item|
        item.product_variant.increment!(:stock_quantity, item.quantity)
      end
    end
  end
  
  def send_status_notification
    # Email notifications should always be sent on status change
    OrderMailer.status_changed(self).deliver_later
  end
  
  def update_product_stock_counts
    # Aggregate calculations that should always be up-to-date
    product_ids = order_items.pluck(:product_id).uniq
    product_ids.each do |product_id|
      Product.find(product_id).update_stock_aggregates
    end
  end
end

# ✅ GOOD: Use Rails Admin hooks to call services for complex workflows
# Location: config/initializers/rails_admin_hooks.rb
Rails.application.config.to_prepare do
  # Hook into Rails Admin create/update actions
  RailsAdmin::Config::Actions::Create.class_eval do
    register_instance_option :controller do
      proc do
        if request.post? && params[:order]
          # For complex operations, call service even from Rails Admin
          service = Orders::CreationService.new(
            User.find(params[:order][:user_id]),
            nil, # No cart for admin-created orders
            order_params
          )
          service.call
          
          if service.success?
            @object = service.result
            flash[:success] = 'Order created successfully'
            redirect_to rails_admin.show_path(model_name: 'order', id: @object.id)
          else
            flash[:error] = service.errors.join(', ')
            redirect_to rails_admin.new_path(model_name: 'order')
          end
        else
          # Default Rails Admin behavior for simple models
          @authorization_adapter.try(:authorize, :create, @abstract_model, @object)
          if request.post? && params[@abstract_model.param_key]
            @object.set_attributes(params[@abstract_model.param_key])
            @authorization_adapter.try(:authorize, :create, @abstract_model, @object)
            if @object.save
              @auditing_adapter&.create_object(@object, @abstract_model, _current_user)
              redirect_to_on_success
            else
              handle_save_error :create
            end
          end
        end
      end
    end
  end
end

# ✅ GOOD: Use concerns to encapsulate business logic that should run everywhere
# Location: app/models/concerns/order_workflow.rb
module OrderWorkflow
  extend ActiveSupport::Concern
  
  included do
    # Callbacks that ensure business rules are always enforced
    before_update :validate_status_transition
    after_update :handle_status_change_effects, if: :saved_change_to_status?
  end
  
  private
  
  def validate_status_transition
    # Business rule: can't move from 'delivered' to 'pending'
    if status_changed? && status_was == 'delivered' && status != 'cancelled'
      errors.add(:status, 'Cannot change status from delivered')
      throw(:abort)
    end
  end
  
  def handle_status_change_effects
    # This runs whether updated via API, Rails Admin, or Admin View
    case status
    when 'cancelled'
      refund_payment_if_paid
      restore_inventory
    when 'shipped'
      send_shipping_notification
      update_tracking
    when 'delivered'
      mark_order_items_delivered
      trigger_review_request
    end
  end
  
  def refund_payment_if_paid
    return unless payment_status == 'paid'
    Payments::RefundService.new(self).call
  end
  
  def restore_inventory
    order_items.each do |item|
      item.product_variant.increment!(:stock_quantity, item.quantity)
    end
  end
  
  def send_shipping_notification
    OrderMailer.shipped(self).deliver_later
  end
  
  def update_tracking
    # Update tracking information
  end
  
  def mark_order_items_delivered
    order_items.update_all(fulfillment_status: 'delivered', delivered_at: Time.current)
  end
  
  def trigger_review_request
    # Schedule review request email
    ReviewRequestJob.set(wait: 7.days).perform_later(id)
  end
end

# Usage in model:
# class Order < ApplicationRecord
#   include OrderWorkflow
# end

# ✅ GOOD: Distinguish between data integrity (model) and workflow (service)
# 
# MODEL LEVEL (always runs):
# - Data validations (presence, format, uniqueness)
# - Referential integrity (foreign keys, associations)
# - Automatic calculations (totals, aggregates)
# - Status transition validations
# - Audit logging
# - Side effects that must always happen (inventory updates, notifications)
#
# SERVICE LEVEL (controller-initiated):
# - Complex multi-step workflows
# - External API calls
# - Conditional business logic based on user context
# - Transaction management for multiple models
# - Error handling and rollback strategies

# Example: Order creation
# 
# MODEL (Order):
#   - Validates required fields
#   - Generates order number
#   - Calculates totals
#   - Updates inventory counts
#
# SERVICE (Orders::CreationService):
#   - Validates cart contents
#   - Creates order (triggers model callbacks)
#   - Transfers cart items
#   - Applies coupon (complex validation)
#   - Processes payment
#   - Sends confirmation email
#   - Handles errors and rollback

# ✅ GOOD: Rails Admin configuration with service integration
# Location: config/initializers/rails_admin.rb
RailsAdmin.config do |config|
  config.model 'Order' do
    edit do
      # Use Rails Admin hooks to call services for complex operations
      field :status do
        # When status is changed in Rails Admin, ensure business logic runs
        html_attributes do
          {
            onchange: "if(confirm('This will trigger order status workflow. Continue?')) { return true; } else { return false; }"
          }
        end
      end
    end
    
    # Override create/update actions to use services
    # (See rails_admin_hooks.rb example above)
  end
end

# ✅ GOOD: Admin view controllers should also use services
# Location: app/controllers/admin/orders_controller.rb
class Admin::OrdersController < ApplicationController
  def update
    @order = Order.find(params[:id])
    
    # For complex updates, use service
    if params[:order][:status].present?
      service = Orders::StatusUpdateService.new(
        @order,
        params[:order][:status],
        current_admin
      )
      service.call
      
      if service.success?
        redirect_to admin_order_path(@order), notice: 'Order updated successfully'
      else
        flash[:error] = service.errors.join(', ')
        render :edit
      end
    else
      # Simple field updates can use direct model update
      if @order.update(order_params)
        redirect_to admin_order_path(@order), notice: 'Order updated successfully'
      else
        render :edit
      end
    end
  end
end

# ❌ BAD: Business logic only in services (bypassed by Rails Admin)
class Order < ApplicationRecord
  # No validations or callbacks
  # All logic in Orders::CreationService
end

# When updated via Rails Admin:
# - No validations run
# - No side effects triggered
# - Inventory not updated
# - Emails not sent
# - Data becomes inconsistent

# ❌ BAD: Duplicating logic in multiple places
# Don't put the same validation in:
# - Service
# - Model
# - Rails Admin hook
# - Admin controller
#
# Instead: Put it in the model (always runs) or a concern (reusable)

# ============================================================================
# DECISION TREE: Where should this business logic go?
# ============================================================================
#
# ┌─────────────────────────────────────────────────────────────┐
# │ Does it need to run ALWAYS, regardless of entry point?      │
# │ → YES: Model callback or concern                           │
# │ → NO: Continue...                                           │
# └─────────────────────────────────────────────────────────────┘
#                          │
#                          ▼
# ┌─────────────────────────────────────────────────────────────┐
# │ Is it a complex multi-step workflow?                        │
# │ → YES: Service (called from controller/Rails Admin hook)    │
# │ → NO: Continue...                                           │
# └─────────────────────────────────────────────────────────────┘
#                          │
#                          ▼
# ┌─────────────────────────────────────────────────────────────┐
# │ Is it data validation or integrity?                         │
# │ → YES: Model validation                                     │
# │ → NO: Model helper method                                   │
# └─────────────────────────────────────────────────────────────┘
#
# ============================================================================
# BEST PRACTICES SUMMARY
# ============================================================================
#
# 1. DATA INTEGRITY → Model validations and callbacks
#    - Always runs, regardless of entry point
#    - Examples: presence, format, uniqueness, status transitions
#
# 2. SIDE EFFECTS → Model callbacks or concerns
#    - Must happen whenever data changes
#    - Examples: inventory updates, email notifications, audit logs
#
# 3. COMPLEX WORKFLOWS → Services
#    - Called from controllers or Rails Admin hooks
#    - Examples: order creation, payment processing, coupon application
#
# 4. RAILS ADMIN INTEGRATION → Hooks to call services
#    - For complex operations, ensure services are called
#    - For simple updates, model callbacks handle it
#
# 5. REUSABLE BUSINESS LOGIC → Concerns
#    - Include in models that need the same behavior
#    - Examples: OrderWorkflow, StatusTrackable, PriceAggregatable
#
# ============================================================================


# ============================================================================
# 9. WHAT NOT TO DO (Anti-patterns)
# ============================================================================

# ❌ DON'T: Put business logic in controllers
# ❌ DON'T: Put complex workflows in models (use services for multi-step operations)
# ❌ DON'T: Put business logic ONLY in services (use model callbacks for data integrity)
# ❌ DON'T: Create repository layer for ActiveRecord (use scopes)
# ❌ DON'T: Send emails from models for complex workflows (use services, but model callbacks OK for simple notifications)
# ❌ DON'T: Put presentation logic in controllers (use serializers/presenters)
# ❌ DON'T: Create services for simple ActiveRecord queries (use scopes)
# ❌ DON'T: Over-engineer with unnecessary abstractions (YAGNI)
# ❌ DON'T: Duplicate code across services (extract to concerns or base classes)
# ❌ DON'T: Put complex calculations in views (use presenters)
# ❌ DON'T: Access external APIs directly from models (use services)
# ❌ DON'T: Bypass business logic when updating via Rails Admin (use hooks or model callbacks)


# ============================================================================
# 10. FILE ORGANIZATION
# ============================================================================

# Controllers:
#   app/controllers/api/v1/*_controller.rb        # API endpoints
#   app/controllers/admin/*_controller.rb         # Admin panel
#   app/controllers/concerns/*.rb                 # Controller concerns``

# Services:
#   app/services/*_service.rb                     # Simple services
#   app/services/{namespace}/*_service.rb        # Namespaced services
#   app/services/base_service.rb                 # Base class

# Models:
#   app/models/*.rb                              # Models
#   app/models/concerns/*.rb                     # Model concerns

# Serializers:
#   app/serializers/*_serializer.rb              # API serializers
#   app/serializers/base_serializer.rb           # Base class

# Presenters:
#   app/presenters/*_presenter.rb                # Admin presenters

# Value Objects:
#   app/value_objects/*.rb                        # Value objects (Money, Discount, etc.)


# ============================================================================
# END OF CODE STYLE GUIDE
# ============================================================================

