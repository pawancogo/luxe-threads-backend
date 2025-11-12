# frozen_string_literal: true

# Service for generating category navigation data
class CategoryNavigationService < BaseService
  attr_reader :navigation_data

  def initialize
    super()
  end

  def call
    generate_navigation
    set_result(@navigation_data)
    self
  rescue StandardError => e
    handle_error(e)
    self
  end

  private

  def generate_navigation
    root_categories = Category.root_categories.includes(:sub_categories).order(:sort_order, :name)
    @navigation_data = root_categories.map do |category|
      {
        id: category.slug || category.id.to_s,
        name: category.name,
        subcategories: format_subcategories_for_nav(category, category.sub_categories)
      }
    end
  end

  def format_subcategories_for_nav(parent_category, sub_categories)
    sections = []
    
    if sub_categories.any?
      sections << {
        title: parent_category.name,
        items: sub_categories.map { |sub| sub.name }
      }
    end
    
    sections
  end
end

