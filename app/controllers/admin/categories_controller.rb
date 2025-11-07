# frozen_string_literal: true

class Admin::CategoriesController < Admin::BaseController
    before_action :set_category, only: [:show, :edit, :update, :destroy]

    def index
      @categories = Category._search(params).order(:name)
      @filters.merge!(@categories.filter_with_aggs)
    end

    def show
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      
      if @category.save
        redirect_to admin_category_path(@category), notice: 'Category created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @category.update(category_params)
        redirect_to admin_category_path(@category), notice: 'Category updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @category.destroy
      redirect_to admin_categories_path, notice: 'Category deleted successfully.'
    end

    def bulk_action
      category_ids = params[:category_ids]&.split(',') || []
      action = params[:bulk_action]
      
      return redirect_to admin_categories_path, alert: 'Please select at least one category.' if category_ids.empty?
      
      categories = Category.where(id: category_ids)
      count = 0
      
      case action
      when 'feature'
        categories.update_all(featured: true)
        count = categories.count
        notice = "#{count} category(ies) featured successfully."
      when 'unfeature'
        categories.update_all(featured: false)
        count = categories.count
        notice = "#{count} category(ies) unfeatured successfully."
      when 'delete'
        categories.destroy_all
        count = categories.count
        notice = "#{count} category(ies) deleted successfully."
      else
        return redirect_to admin_categories_path, alert: 'Invalid action.'
      end
      
      redirect_to admin_categories_path, notice: notice
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :short_description, :parent_id, :featured, :image_url, :sort_order)
    end
  end

