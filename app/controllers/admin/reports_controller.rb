# frozen_string_literal: true

class Admin::ReportsController < Admin::BaseController
    def index
      # Reports dashboard
      @start_date = params[:start_date]&.to_date || 30.days.ago.to_date
      @end_date = params[:end_date]&.to_date || Date.current
    end

    def sales
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      @report_data = service.sales_report
      render :sales
    end

    def products
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      @report_data = service.products_report
      render :products
    end

    def users
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      @report_data = service.users_report
      render :users
    end

    def suppliers
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      @report_data = service.suppliers_report
      render :suppliers
    end

    def revenue
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      @report_data = service.revenue_report
      render :revenue
    end

    def returns
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      @report_data = service.returns_report
      render :returns
    end

    def export
      # CSV export functionality
      report_type = params[:report_type] || 'sales'
      service = AdminReportsService.new(
        start_date: params[:start_date]&.to_date,
        end_date: params[:end_date]&.to_date
      )
      
      require 'csv'
      csv_data = CSV.generate(headers: true) do |csv|
        # Generate CSV based on report_type
      end
      
      send_data csv_data,
                filename: "#{report_type}_report_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
                type: 'text/csv'
    end
  end

