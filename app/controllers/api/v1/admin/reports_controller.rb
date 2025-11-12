# frozen_string_literal: true

module Api::V1::Admin
  class ReportsController < BaseController
    include AdminApiAuthorization
    
    before_action :require_super_admin_or_order_admin!, only: [:sales, :revenue, :returns]
    before_action :require_super_admin_or_product_admin!, only: [:products]
    before_action :require_super_admin_or_user_admin!, only: [:users, :suppliers]
    
    # GET /api/v1/admin/reports/sales
    def sales
      service = Admins::Reports::SalesReportService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      service.call
      
      if service.failure?
        render_error('Failed to generate sales report', service.errors.join(', '))
      else
        render_success(service.result, 'Sales report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/products
    def products
      service = Admins::Reports::ProductsReportService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      service.call
      
      if service.failure?
        render_error('Failed to generate products report', service.errors.join(', '))
      else
        render_success(service.result, 'Products report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/users
    def users
      service = Admins::Reports::UsersReportService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      service.call
      
      if service.failure?
        render_error('Failed to generate users report', service.errors.join(', '))
      else
        render_success(service.result, 'Users report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/suppliers
    def suppliers
      service = Admins::Reports::SuppliersReportService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      service.call
      
      if service.failure?
        render_error('Failed to generate suppliers report', service.errors.join(', '))
      else
        render_success(service.result, 'Suppliers report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/revenue
    def revenue
      service = Admins::Reports::RevenueReportService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      service.call
      
      if service.failure?
        render_error('Failed to generate revenue report', service.errors.join(', '))
      else
        render_success(service.result, 'Revenue report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/returns
    def returns
      service = Admins::Reports::ReturnsReportService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      service.call
      
      if service.failure?
        render_error('Failed to generate returns report', service.errors.join(', '))
      else
        render_success(service.result, 'Returns report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/export
    def export
      report_type = params[:report_type] || 'sales'
      service_class = case report_type
                      when 'sales' then Admins::Reports::SalesReportService
                      when 'products' then Admins::Reports::ProductsReportService
                      when 'users' then Admins::Reports::UsersReportService
                      when 'suppliers' then Admins::Reports::SuppliersReportService
                      when 'revenue' then Admins::Reports::RevenueReportService
                      when 'returns' then Admins::Reports::ReturnsReportService
                      else Admins::Reports::SalesReportService
                      end
      
      service = service_class.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      service.call
      report_data = service.result
      
      require 'csv'
      csv_data = CSV.generate(headers: true) do |csv|
        case report_type
        when 'sales'
          csv << ['Date', 'Orders', 'Revenue']
          daily_stats = report_data[:daily_stats] || []
          daily_stats.each do |stat|
            csv << [stat[:date], stat[:orders_count], stat[:revenue]]
          end
        when 'products'
          csv << ['Status', 'Count', 'Percentage']
          products_by_status = report_data[:products_by_status] || []
          products_by_status.each do |stat|
            csv << [stat[:status], stat[:count], stat[:percentage]]
          end
        when 'users'
          csv << ['Date', 'New Users']
          new_users = report_data[:new_users_daily] || []
          new_users.each do |stat|
            csv << [stat[:date], stat[:count]]
          end
        when 'revenue'
          csv << ['Date', 'Revenue', 'Orders']
          daily_revenue = report_data[:daily_revenue] || []
          daily_revenue.each do |stat|
            csv << [stat[:date], stat[:revenue], stat[:orders_count]]
          end
        when 'returns'
          csv << ['Date', 'Returns Count']
          daily_returns = report_data[:daily_returns] || []
          daily_returns.each do |stat|
            csv << [stat[:date], stat[:count]]
          end
        end
      end
      
      send_data csv_data,
                filename: "#{report_type}_report_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
                type: 'text/csv'
    end
    
    private
    
    def require_super_admin_or_order_admin!
      require_role!(['super_admin', 'order_admin'])
    end
    
    def require_super_admin_or_product_admin!
      require_role!(['super_admin', 'product_admin'])
    end
    
    def require_super_admin_or_user_admin!
      require_role!(['super_admin', 'user_admin'])
    end
  end
end

