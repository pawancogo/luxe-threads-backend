# frozen_string_literal: true

module Api::V1::Admin
  class ProductsController < BaseController
    include AdminApiAuthorization
    
    before_action :require_product_admin_role!, only: [:index, :show, :update, :destroy, :approve, :reject, :bulk_approve, :bulk_reject, :export]
    before_action :set_product, only: [:show, :update, :destroy, :approve, :reject]
    
    # GET /api/v1/admin/products
    def index
      @products = Product.includes(:supplier_profile, :category, :brand, :product_variants, verified_by_admin: [])
                         .order(created_at: :desc)
      
      # Filters
      @products = @products.where(status: params[:status]) if params[:status].present?
      @products = @products.where(supplier_profile_id: params[:supplier_id]) if params[:supplier_id].present?
      @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
      @products = @products.where(brand_id: params[:brand_id]) if params[:brand_id].present?
      @products = @products.where('name LIKE ?', "%#{params[:search]}%") if params[:search].present?
      
      # Date range filter
      if params[:created_from].present?
        @products = @products.where('created_at >= ?', params[:created_from])
      end
      if params[:created_to].present?
        @products = @products.where('created_at <= ?', params[:created_to])
      end
      
      # Pagination
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 20
      @products = @products.page(page).per(per_page)
      
      render_success(format_products_data(@products), 'Products retrieved successfully')
    end
    
    # GET /api/v1/admin/products/:id
    def show
      render_success(format_product_detail_data(@product), 'Product retrieved successfully')
    end
    
    # PATCH /api/v1/admin/products/:id
    def update
      product_params_data = params[:product] || {}
      
      # Allow admin to edit product fields
      update_hash = {}
      update_hash[:name] = product_params_data[:name] if product_params_data.key?(:name)
      update_hash[:description] = product_params_data[:description] if product_params_data.key?(:description)
      update_hash[:short_description] = product_params_data[:short_description] if product_params_data.key?(:short_description)
      update_hash[:category_id] = product_params_data[:category_id] if product_params_data.key?(:category_id)
      update_hash[:brand_id] = product_params_data[:brand_id] if product_params_data.key?(:brand_id)
      update_hash[:is_featured] = product_params_data[:is_featured] if product_params_data.key?(:is_featured)
      update_hash[:is_bestseller] = product_params_data[:is_bestseller] if product_params_data.key?(:is_bestseller)
      update_hash[:status] = product_params_data[:status] if product_params_data.key?(:status)
      
      if @product.update(update_hash)
        log_admin_activity('update', 'Product', @product.id, @product.previous_changes)
        render_success(format_product_detail_data(@product), 'Product updated successfully')
      else
        render_validation_errors(@product.errors.full_messages, 'Product update failed')
      end
    end
    
    # DELETE /api/v1/admin/products/:id
    def destroy
      product_id = @product.id
      if @product.destroy
        log_admin_activity('destroy', 'Product', product_id)
        render_success({ id: product_id }, 'Product deleted successfully')
      else
        render_validation_errors(@product.errors.full_messages, 'Product deletion failed')
      end
    end
    
    # PATCH /api/v1/admin/products/:id/approve
    def approve
      if @product.update(
        status: :active,
        verified_by_admin_id: @current_admin.id,
        verified_at: Time.current,
        rejection_reason: nil
      )
        log_admin_activity('approve', 'Product', @product.id, { status: [@product.status_before_last_save, 'active'] })
        render_success(format_product_detail_data(@product), 'Product approved successfully')
      else
        render_validation_errors(@product.errors.full_messages, 'Product approval failed')
      end
    end
    
    # PATCH /api/v1/admin/products/:id/reject
    def reject
      rejection_reason = params[:rejection_reason] || params.dig(:product, :rejection_reason)
      
      unless rejection_reason.present?
        render_validation_errors(['Rejection reason is required'], 'Rejection reason must be provided')
        return
      end
      
      if @product.update(
        status: :rejected,
        verified_by_admin_id: @current_admin.id,
        verified_at: Time.current,
        rejection_reason: rejection_reason
      )
        log_admin_activity('reject', 'Product', @product.id, { 
          status: [@product.status_before_last_save, 'rejected'],
          rejection_reason: [nil, rejection_reason]
        })
        render_success(format_product_detail_data(@product), 'Product rejected successfully')
      else
        render_validation_errors(@product.errors.full_messages, 'Product rejection failed')
      end
    end
    
    # POST /api/v1/admin/products/bulk_approve
    def bulk_approve
      product_ids = params[:product_ids] || []
      
      if product_ids.empty?
        render_validation_errors(['Product IDs are required'], 'Please select at least one product')
        return
      end
      
      products = Product.where(id: product_ids)
      approved_count = 0
      errors = []
      
      products.each do |product|
        if product.update(
          status: :active,
          verified_by_admin_id: @current_admin.id,
          verified_at: Time.current,
          rejection_reason: nil
        )
          approved_count += 1
          log_admin_activity('approve', 'Product', product.id, { status: [product.status_before_last_save, 'active'] })
        else
          errors << "Failed to approve product #{product.id}: #{product.errors.full_messages.join(', ')}"
        end
      end
      
      if errors.any?
        render_success(
          { 
            approved_count: approved_count,
            total_count: product_ids.length,
            errors: errors
          },
          "Approved #{approved_count} of #{product_ids.length} products"
        )
      else
        render_success(
          { approved_count: approved_count, total_count: product_ids.length },
          "Successfully approved #{approved_count} products"
        )
      end
    end
    
    # POST /api/v1/admin/products/bulk_reject
    def bulk_reject
      product_ids = params[:product_ids] || []
      rejection_reason = params[:rejection_reason] || 'Bulk rejection'
      
      if product_ids.empty?
        render_validation_errors(['Product IDs are required'], 'Please select at least one product')
        return
      end
      
      products = Product.where(id: product_ids)
      rejected_count = 0
      errors = []
      
      products.each do |product|
        if product.update(
          status: :rejected,
          verified_by_admin_id: @current_admin.id,
          verified_at: Time.current,
          rejection_reason: rejection_reason
        )
          rejected_count += 1
          log_admin_activity('reject', 'Product', product.id, { 
            status: [product.status_before_last_save, 'rejected'],
            rejection_reason: [nil, rejection_reason]
          })
        else
          errors << "Failed to reject product #{product.id}: #{product.errors.full_messages.join(', ')}"
        end
      end
      
      if errors.any?
        render_success(
          { 
            rejected_count: rejected_count,
            total_count: product_ids.length,
            errors: errors
          },
          "Rejected #{rejected_count} of #{product_ids.length} products"
        )
      else
        render_success(
          { rejected_count: rejected_count, total_count: product_ids.length },
          "Successfully rejected #{rejected_count} products"
        )
      end
    end
    
    # GET /api/v1/admin/products/export
    def export
      @products = Product.includes(:supplier_profile, :category, :brand)
                         .order(created_at: :desc)
      
      # Apply same filters as index
      @products = @products.where(status: params[:status]) if params[:status].present?
      @products = @products.where(supplier_profile_id: params[:supplier_id]) if params[:supplier_id].present?
      @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
      
      # Generate CSV
      require 'csv'
      csv_data = CSV.generate(headers: true) do |csv|
        csv << ['ID', 'Name', 'Supplier', 'Category', 'Brand', 'Status', 'Created At', 'Verified At', 'Rejection Reason']
        
        @products.each do |product|
          csv << [
            product.id,
            product.name,
            product.supplier_profile&.company_name || 'N/A',
            product.category&.name || 'N/A',
            product.brand&.name || 'N/A',
            product.status,
            product.created_at,
            product.verified_at,
            product.rejection_reason
          ]
        end
      end
      
      send_data csv_data, 
                filename: "products_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
                type: 'text/csv'
    end
    
    private
    
    def require_product_admin_role!
      require_role!(['super_admin', 'product_admin'])
    end
    
    def set_product
      @product = Product.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_not_found('Product not found')
    end
    
    def format_products_data(products)
      products.map { |product| format_product_data(product) }
    end
    
    def format_product_data(product)
      {
        id: product.id,
        name: product.name,
        slug: product.slug,
        description: product.description,
        short_description: product.short_description,
        status: product.status,
        supplier: {
          id: product.supplier_profile&.id,
          company_name: product.supplier_profile&.company_name
        },
        category: {
          id: product.category&.id,
          name: product.category&.name
        },
        brand: {
          id: product.brand&.id,
          name: product.brand&.name
        },
        base_price: product.base_price&.to_f,
        is_featured: product.is_featured,
        is_bestseller: product.is_bestseller,
        verified_at: product.verified_at,
        verified_by: product.verified_by_admin&.full_name,
        rejection_reason: product.rejection_reason,
        created_at: product.created_at,
        variants_count: product.product_variants.count
      }
    end
    
    def format_product_detail_data(product)
      format_product_data(product).merge(
        highlights: product.highlights_array,
        tags: product.tags_array,
        variants: product.product_variants.map do |variant|
          {
            id: variant.id,
            sku: variant.sku,
            price: variant.price.to_f,
            stock_quantity: variant.stock_quantity,
            status: variant.out_of_stock? ? 'out_of_stock' : 'in_stock'
          }
        end
      )
    end
  end
end

