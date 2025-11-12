# frozen_string_literal: true

class Admin::ReportsController < Admin::BaseController
  def index
    # Reports dashboard
    @start_date = params[:start_date]&.to_date || 30.days.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.current
  end

  def sales
    service = Admins::Reports::SalesReportService.new(
      start_date: params[:start_date]&.to_date,
      end_date: params[:end_date]&.to_date
    )
    service.call
    @report_data = service.result
    render :sales
  end

  def products
    service = Admins::Reports::ProductsReportService.new(
      start_date: params[:start_date]&.to_date,
      end_date: params[:end_date]&.to_date
    )
    service.call
    @report_data = service.result
    render :products
  end

  def users
    service = Admins::Reports::UsersReportService.new(
      start_date: params[:start_date]&.to_date,
      end_date: params[:end_date]&.to_date
    )
    service.call
    @report_data = service.result
    render :users
  end

  def suppliers
    service = Admins::Reports::SuppliersReportService.new(
      start_date: params[:start_date]&.to_date,
      end_date: params[:end_date]&.to_date
    )
    service.call
    @report_data = service.result
    render :suppliers
  end

  def revenue
    service = Admins::Reports::RevenueReportService.new(
      start_date: params[:start_date]&.to_date,
      end_date: params[:end_date]&.to_date
    )
    service.call
    @report_data = service.result
    render :revenue
  end

  def returns
    service = Admins::Reports::ReturnsReportService.new(
      start_date: params[:start_date]&.to_date,
      end_date: params[:end_date]&.to_date
    )
    service.call
    @report_data = service.result
    render :returns
  end

  def export
    # CSV export functionality
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
    
    require 'csv'
    csv_data = CSV.generate(headers: true) do |csv|
      # Generate CSV based on report_type
    end
    
    send_data csv_data,
              filename: "#{report_type}_report_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
              type: 'text/csv'
  end
end

