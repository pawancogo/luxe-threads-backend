# frozen_string_literal: true

# Query object for complex order queries
class OrderQuery
  attr_reader :scope

  def initialize(scope = Order.all)
    @scope = scope
  end

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
    @scope = scope.order(created_at: direction)
    self
  end

  def result
    @scope
  end

  delegate :to_a, :each, :map, :count, :exists?, :find, :find_by, to: :result
end

