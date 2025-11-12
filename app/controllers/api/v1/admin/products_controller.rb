# frozen_string_literal: true

module Api::V1::Admin
  class ProductsController < BaseController
    include AdminApiAuthorization
    
    before_action :require_product_admin_role!, only: [:index, :show, :update, :destroy, :approve, :reject, :bulk_approve, :bulk_reject, :export]
    before_action :set_product, only: [:show, :update, :destroy, :approve, :reject]
    
    # GET /api/v1/admin/products
    def index
      service = Products::AdminListingService.new(params)
      service.call
      
      if service.success?
        render_success(
          AdminProductSerializer.collection(service.products),
          'Products retrieved successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to retrieve products')
      end
    end
    
    # GET /api/v1/admin/products/:id
    def show
      render_success(
        AdminProductSerializer.new(@product).as_json,
        'Product retrieved successfully'
      )
    end
    
    # PATCH /api/v1/admin/products/:id
    def update
      permitted_params = product_update_params
      
      service = Products::UpdateService.new(@product, permitted_params)
      service.call
      
      if service.success?
        log_admin_activity('update', 'Product', @product.id, @product.previous_changes)
        render_success(
          AdminProductSerializer.new(@product.reload).as_json,
          'Product updated successfully'
        )
      else
        render_validation_errors(service.errors, 'Product update failed')
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
      service = Products::ApprovalService.new(@product, @current_admin)
      service.call
      
      if service.success?
        log_admin_activity('approve', 'Product', @product.id, { status: [@product.status_before_last_save, 'active'] })
        render_success(
          AdminProductSerializer.new(@product.reload).as_json,
          'Product approved successfully'
        )
      else
        render_validation_errors(service.errors, 'Product approval failed')
      end
    end
    
    # PATCH /api/v1/admin/products/:id/reject
    def reject
      rejection_reason = params[:rejection_reason] || params.dig(:product, :rejection_reason)
      
      service = Products::RejectionService.new(@product, @current_admin, rejection_reason: rejection_reason)
      service.call
      
      if service.success?
        log_admin_activity('reject', 'Product', @product.id, { 
          status: [@product.status_before_last_save, 'rejected'],
          rejection_reason: [nil, rejection_reason]
        })
        render_success(
          AdminProductSerializer.new(@product.reload).as_json,
          'Product rejected successfully'
        )
      else
        render_validation_errors(service.errors, 'Product rejection failed')
      end
    end
    
    # POST /api/v1/admin/products/bulk_approve
    def bulk_approve
      product_ids = params[:product_ids] || []
      
      service = Products::BulkApprovalService.new(product_ids, @current_admin)
      service.call
      
      if service.success?
        approved_count = service.products.count
        service.products.each do |product|
          log_admin_activity('approve', 'Product', product.id, { status: ['pending', 'active'] })
        end
        
        render_success(
          { approved_count: approved_count, total_count: product_ids.length },
          "Successfully approved #{approved_count} products"
        )
      else
        render_validation_errors(service.errors, 'Bulk approval failed')
      end
    end
    
    # POST /api/v1/admin/products/bulk_reject
    def bulk_reject
      product_ids = params[:product_ids] || []
      rejection_reason = params[:rejection_reason] || 'Bulk rejection'
      
      service = Products::BulkRejectionService.new(product_ids, @current_admin, rejection_reason: rejection_reason)
      service.call
      
      if service.success?
        rejected_count = service.products.count
        service.products.each do |product|
          log_admin_activity('reject', 'Product', product.id, { 
            status: ['pending', 'rejected'],
            rejection_reason: [nil, rejection_reason]
          })
        end
        
        render_success(
          { rejected_count: rejected_count, total_count: product_ids.length },
          "Successfully rejected #{rejected_count} products"
        )
      else
        render_validation_errors(service.errors, 'Bulk rejection failed')
      end
    end
    
    # GET /api/v1/admin/products/export
    def export
      @products = Product.includes(:supplier_profile, :category, :brand)
                         .with_status(params[:status])
                         .by_supplier(params[:supplier_id])
                         .by_category(params[:category_id])
                         .order(created_at: :desc)
      
      service = Products::ExportService.new(@products)
      service.call
      
      if service.success?
        send_data service.csv_data, 
                  filename: service.filename,
                  type: 'text/csv'
      else
        render_error(service.errors.first || 'Failed to export products', :unprocessable_entity)
      end
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
    
    def product_update_params
      (params[:product] || {}).permit(
        :name, :description, :short_description, :category_id, 
        :brand_id, :is_featured, :is_bestseller, :status
      ).compact
    end
    
  end
end

