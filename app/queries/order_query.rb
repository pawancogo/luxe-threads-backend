# frozen_string_literal: true

# Query object for complex order queries
class OrderQuery < BaseQuery
  def initialize(scope = nil)
    super(scope)
  end

  protected

  def default_scope
    Order.all
  end

  public

  def for_user(user_id)
    @scope = scope.where(user_id: user_id)
    self
  end

  def with_status(status)
    @scope = scope.where(status: status) if status.present?
    self
  end

  def with_payment_status(payment_status)
    @scope = scope.where(payment_status: payment_status) if payment_status.present?
    self
  end

  def recent(days = 30)
    @scope = scope.where('created_at >= ?', days.days.ago)
    self
  end

  def with_items
    @scope = scope.includes(:order_items)
    self
  end

  def order_by_date(direction = :desc)
    order_by_created(direction)
  end
end

