class Api::V1::CategoriesController < ApplicationController
  skip_before_action :authenticate_request, only: [:index, :show, :navigation]

  def index
    @categories = Category.includes(:parent)
                          .order(:sort_order, :name)
                          .all
    render_success(format_categories_data(@categories), 'Categories retrieved successfully')
  end

  def show
    @category = Category.find_by(slug: params[:id]) || Category.find(params[:id])
    render_success(format_category_data(@category), 'Category retrieved successfully')
  rescue ActiveRecord::RecordNotFound
    render_not_found('Category not found')
  end

  def navigation
    # Return root categories with their subcategories for navigation menu
    root_categories = Category.root_categories.includes(:sub_categories).order(:sort_order, :name)
    navigation_data = root_categories.map do |category|
      {
        id: category.slug || category.id.to_s,
        name: category.name,
        subcategories: format_subcategories_for_nav(category, category.sub_categories)
      }
    end
    render_success(navigation_data, 'Navigation items retrieved successfully')
  end

  private

  def format_subcategories_for_nav(parent_category, sub_categories)
    # Group subcategories and create sections
    sections = []
    
    if sub_categories.any?
      # If subcategories exist, create sections
      # For now, create a single section with all subcategories
      # You can enhance this to group by parent categories if needed
      sections << {
        title: parent_category.name,
        items: sub_categories.map { |sub| sub.name }
      }
    end
    
    sections
  end

  def format_categories_data(categories)
    categories.map do |category|
      {
        id: category.id,
        name: category.name,
        slug: category.slug,
        parent_id: category.parent_id,
        level: category.level,
        path: category.path,
        short_description: category.short_description,
        image_url: category.image_url,
        banner_url: category.banner_url,
        icon_url: category.icon_url,
        featured: category.featured || false,
        products_count: category.products_count || 0,
        active_products_count: category.active_products_count || 0,
        parent: category.parent ? {
          id: category.parent.id,
          name: category.parent.name,
          slug: category.parent.slug
        } : nil,
        sub_categories: category.sub_categories.map do |sub|
          {
            id: sub.id,
            name: sub.name,
            slug: sub.slug
          }
        end
      }
    end
  end

  def format_category_data(category)
    {
      id: category.id,
      name: category.name,
      slug: category.slug,
      parent_id: category.parent_id,
      level: category.level,
      path: category.path,
      short_description: category.short_description,
      description: category.description,
      image_url: category.image_url,
      banner_url: category.banner_url,
      icon_url: category.icon_url,
      meta_title: category.meta_title,
      meta_description: category.meta_description,
      meta_keywords: category.meta_keywords,
      featured: category.featured || false,
      products_count: category.products_count || 0,
      active_products_count: category.active_products_count || 0,
      parent: category.parent ? {
        id: category.parent.id,
        name: category.parent.name,
        slug: category.parent.slug
      } : nil
    }
  end

  def format_collection_data(collection)
    collection.map(&:as_json)
  end
end