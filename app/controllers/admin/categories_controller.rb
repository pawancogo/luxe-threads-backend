# frozen_string_literal: true

class Admin::CategoriesController < Admin::BaseController
    before_action :set_category, only: [:show, :edit, :update, :destroy]

    def index
      search_params = params.except(:controller, :action).permit(:search, :per_page, :page, :featured, :level, :date_range, :min, :max)
      search_options = {}
      search_options[:range_field] = @filters[:range_field] if @filters[:range_field].present?
      
      @categories = Category._search(search_params, **search_options).order(:name)
      
      # Merge filters (this will include aggregations)
      begin
        filter_aggs = @categories.filter_with_aggs if @categories.respond_to?(:filter_with_aggs)
        @filters.merge!(filter_aggs) if filter_aggs.present?
      rescue => e
        Rails.logger.error "Error merging filters: #{e.message}"
        @filters ||= { search: [nil] }
      end
    end

    def show
    end

    def new
      @category = Category.new
    end

    def create
      service = Categories::CreationService.new(category_params)
      service.call
      
      if service.success?
        redirect_to admin_category_path(service.category), notice: 'Category created successfully.'
      else
        @category = service.category || Category.new(category_params)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      service = Categories::UpdateService.new(@category, category_params)
      service.call
      
      if service.success?
        redirect_to admin_category_path(@category), notice: 'Category updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      service = Categories::DeletionService.new(@category)
      service.call
      
      if service.success?
        redirect_to admin_categories_path, notice: 'Category deleted successfully.'
      else
        redirect_to admin_categories_path, alert: service.errors.first || 'Failed to delete category'
      end
    end

    def bulk_action
      category_ids = params[:category_ids]&.split(',') || []
      action = params[:bulk_action]
      
      service = CategoryBulkActionService.new(category_ids, action)
      service.call
      
      if service.success?
        count = service.count
        action_name = action == 'feature' ? 'featured' : action == 'unfeature' ? 'unfeatured' : 'deleted'
        notice = "#{count} category(ies) #{action_name} successfully."
        redirect_to admin_categories_path, notice: notice
      else
        redirect_to admin_categories_path, alert: service.errors.first || 'Bulk action failed'
      end
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :short_description, :parent_id, :featured, :image_url, :sort_order)
    end
  end

