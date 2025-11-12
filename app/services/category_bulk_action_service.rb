# frozen_string_literal: true

# Service for performing bulk actions on categories
class CategoryBulkActionService < BaseService
  attr_reader :categories, :count

  def initialize(category_ids, action)
    super()
    @category_ids = Array(category_ids)
    @action = action.to_s
  end

  def call
    validate!
    perform_action
    set_result({ count: @count, categories: @categories })
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def validate!
    if @category_ids.empty?
      add_error('Please select at least one category')
      raise StandardError, 'No categories selected'
    end

    unless ['feature', 'unfeature', 'delete'].include?(@action)
      add_error('Invalid action')
      raise StandardError, 'Invalid action'
    end
  end

  def perform_action
    @categories = Category.where(id: @category_ids)
    
    case @action
    when 'feature'
      @categories.update_all(featured: true)
      @count = @categories.count
    when 'unfeature'
      @categories.update_all(featured: false)
      @count = @categories.count
    when 'delete'
      @count = @categories.count
      @categories.destroy_all
    end
  end
end

