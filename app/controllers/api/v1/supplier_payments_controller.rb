# frozen_string_literal: true

class Api::V1::SupplierPaymentsController < ApplicationController
  before_action :set_supplier_payment, only: [:show]
  before_action :authorize_supplier!, only: [:index, :show]
  before_action :authorize_admin!, only: [:admin_index, :admin_create]

  # GET /api/v1/supplier/payments
  def index
    ensure_supplier_profile!
    
    @supplier_payments = SupplierPayment.where(supplier_profile_id: current_user.supplier_profile.id)
                                       .includes(:supplier_profile, :processed_by)
                                       .order(created_at: :desc)
    
    # Filter by status if provided
    @supplier_payments = @supplier_payments.where(status: params[:status]) if params[:status].present?
    
    render_success(format_supplier_payments_data(@supplier_payments), 'Supplier payments retrieved successfully')
  end

  # GET /api/v1/supplier/payments/:id
  def show
    ensure_supplier_profile!
    
    # Check authorization
    unless @supplier_payment.supplier_profile_id == current_user.supplier_profile.id
      render_unauthorized('Not authorized')
      return
    end
    
    render_success(format_supplier_payment_detail_data(@supplier_payment), 'Supplier payment retrieved successfully')
  end

  # GET /api/v1/admin/supplier_payments
  def admin_index
    @supplier_payments = SupplierPayment.includes(:supplier_profile, :processed_by)
                                       .order(created_at: :desc)
    
    # Filter by status if provided
    @supplier_payments = @supplier_payments.where(status: params[:status]) if params[:status].present?
    
    # Filter by supplier_profile_id if provided
    @supplier_payments = @supplier_payments.where(supplier_profile_id: params[:supplier_profile_id]) if params[:supplier_profile_id].present?
    
    render_success(format_supplier_payments_data(@supplier_payments), 'Supplier payments retrieved successfully')
  end

  # POST /api/v1/admin/supplier_payments
  def admin_create
    supplier_profile = SupplierProfile.find(params[:supplier_profile_id])
    
    payment_params_data = params[:supplier_payment] || {}
    
    @supplier_payment = SupplierPayment.new(
      supplier_profile: supplier_profile,
      amount: payment_params_data[:amount],
      currency: payment_params_data[:currency] || 'INR',
      payment_method: payment_params_data[:payment_method],
      period_start_date: payment_params_data[:period_start_date],
      period_end_date: payment_params_data[:period_end_date],
      commission_deducted: payment_params_data[:commission_deducted] || 0,
      notes: payment_params_data[:notes],
      status: 'pending',
      processed_by: current_user
    )
    
    if @supplier_payment.save
      render_created(format_supplier_payment_detail_data(@supplier_payment), 'Supplier payment created successfully')
    else
      render_validation_errors(@supplier_payment.errors.full_messages, 'Supplier payment creation failed')
    end
  rescue ActiveRecord::RecordNotFound
    render_not_found('Supplier profile not found')
  end

  private

  def set_supplier_payment
    @supplier_payment = SupplierPayment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found('Supplier payment not found')
  end

  def authorize_supplier!
    render_unauthorized('Supplier access required') unless current_user.supplier?
  end

  def authorize_admin!
    render_unauthorized('Admin access required') unless current_user.admin?
  end

  def ensure_supplier_profile!
    if current_user.supplier_profile.nil?
      render_validation_errors(
        ['Supplier profile not found. Please create a supplier profile first.'],
        'Supplier profile required'
      )
      return
    end
  end

  def format_supplier_payments_data(payments)
    payments.map { |payment| format_supplier_payment_data(payment) }
  end

  def format_supplier_payment_data(payment)
    {
      id: payment.id,
      payment_id: payment.payment_id,
      supplier_profile_id: payment.supplier_profile_id,
      amount: payment.amount.to_f,
      net_amount: payment.net_amount.to_f,
      currency: payment.currency,
      payment_method: payment.payment_method,
      status: payment.status,
      period_start_date: payment.period_start_date&.iso8601,
      period_end_date: payment.period_end_date&.iso8601,
      created_at: payment.created_at&.iso8601,
      processed_at: payment.processed_at&.iso8601,
      commission_deducted: payment.commission_deducted.to_f,
      commission_rate: payment.commission_rate
    }
  end

  def format_supplier_payment_detail_data(payment)
    format_supplier_payment_data(payment).merge(
      commission_deducted: payment.commission_deducted.to_f,
      commission_rate: payment.commission_rate,
      notes: payment.notes,
      bank_account_details: payment.bank_account_details_data,
      transaction_reference: payment.transaction_reference,
      failure_reason: payment.failure_reason,
      processed_by: payment.processed_by ? {
        id: payment.processed_by.id,
        name: payment.processed_by.full_name || payment.processed_by.email
      } : nil,
      supplier_profile: {
        id: payment.supplier_profile.id,
        company_name: payment.supplier_profile.company_name
      }
    )
  end
end

