# frozen_string_literal: true

# Base query object following Query Object pattern
# Provides common functionality for all query objects
class BaseQuery
  attr_reader :scope

  def initialize(scope = nil)
    @scope = scope || default_scope
  end

  # Return the final scope
  def result
    @scope
  end

  # Delegate common ActiveRecord methods
  delegate :to_a, :each, :map, :count, :exists?, :find, :find_by, :first, :last, :limit, :offset, to: :result

  # Pagination support
  def paginate(page: 1, per_page: 20)
    @scope = scope.page(page).per(per_page)
    self
  end

  # Ordering
  def order_by(column, direction = :asc)
    @scope = scope.order("#{column} #{direction.to_s.upcase}")
    self
  end

  # Order by created_at (most common)
  def order_by_created(direction = :desc)
    order_by(:created_at, direction)
  end

  # Order by updated_at
  def order_by_updated(direction = :desc)
    order_by(:updated_at, direction)
  end

  protected

  # Override in subclasses to set default scope
  def default_scope
    raise NotImplementedError, "#{self.class} must implement #default_scope"
  end

  # Chainable scope modification
  def chain(&block)
    @scope = block.call(scope)
    self
  end
end

