# frozen_string_literal: true

module Api::V1::Admin
  class ReportsController < BaseController
    include AdminApiAuthorization
    
    before_action :require_super_admin_or_order_admin!, only: [:sales, :revenue, :returns]
    before_action :require_super_admin_or_product_admin!, only: [:products]
    before_action :require_super_admin_or_user_admin!, only: [:users, :suppliers]
    
    # GET /api/v1/admin/reports/sales
    def sales
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      
      report_data = service.sales_report
      
      if service.errors.any?
        render_error('Failed to generate sales report', service.errors.join(', '))
      else
        render_success(report_data, 'Sales report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/products
    def products
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      
      report_data = service.products_report
      
      if service.errors.any?
        render_error('Failed to generate products report', service.errors.join(', '))
      else
        render_success(report_data, 'Products report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/users
    def users
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      
      report_data = service.users_report
      
      if service.errors.any?
        render_error('Failed to generate users report', service.errors.join(', '))
      else
        render_success(report_data, 'Users report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/suppliers
    def suppliers
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      
      report_data = service.suppliers_report
      
      if service.errors.any?
        render_error('Failed to generate suppliers report', service.errors.join(', '))
      else
        render_success(report_data, 'Suppliers report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/revenue
    def revenue
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      
      report_data = service.revenue_report
      
      if service.errors.any?
        render_error('Failed to generate revenue report', service.errors.join(', '))
      else
        render_success(report_data, 'Revenue report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/returns
    def returns
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      
      report_data = service.returns_report
      
      if service.errors.any?
        render_error('Failed to generate returns report', service.errors.join(', '))
      else
        render_success(report_data, 'Returns report generated successfully')
      end
    end
    
    # GET /api/v1/admin/reports/export
    def export
      report_type = params[:report_type] || 'sales'
      start_date = params[:start_date]&.to_date || 30.days.ago.to_date
      end_date = params[:end_date]&.to_date || Date.current
      
      service = AdminReportsService.new(start_date: start_date, end_date: end_date)
      
      require 'csv'
      csv_data = CSV.generate(headers: true) do |csv|
        case report_type
        when 'sales'
          csv << ['Date', 'Orders', 'Revenue']
          daily_stats = service.sales_report[:daily_stats] || []
          daily_stats.each do |stat|
            csv << [stat[:date], stat[:orders_count], stat[:revenue]]
          end
        when 'products'
          csv << ['Status', 'Count', 'Percentage']
          products_by_status = service.products_report[:products_by_status] || []
          products_by_status.each do |stat|
            csv << [stat[:status], stat[:count], stat[:percentage]]
          end
        when 'users'
          csv << ['Date', 'New Users']
          new_users = service.users_report[:new_users_daily] || []
          new_users.each do |stat|
            csv << [stat[:date], stat[:count]]
          end
        when 'revenue'
          csv << ['Date', 'Revenue', 'Orders']
          daily_revenue = service.revenue_report[:daily_revenue] || []
          daily_revenue.each do |stat|
            csv << [stat[:date], stat[:revenue], stat[:orders_count]]
          end
        when 'returns'
          csv << ['Date', 'Returns Count']
          daily_returns = service.returns_report[:daily_returns] || []
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

