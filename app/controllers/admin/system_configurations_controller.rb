# frozen_string_literal: true

class Admin::SystemConfigurationsController < Admin::BaseController
  before_action :require_super_admin!
  before_action :set_system_configuration, only: [:show, :edit, :update, :destroy, :activate, :deactivate]

  def index
    @system_configurations = SystemConfiguration.order(:category, :key).page(params[:page])
    
    # Role-based filtering: Only show configs created by admins of the same role
    # Super admins can see all configs, other admins only see configs from their role
    unless current_admin.super_admin?
      # Get all admin IDs with the same role as current admin
      admin_ids = Admin.where(role: current_admin.role).pluck(:id)
      # Show configs created by admins of same role OR system-created configs (created_by is nil)
      @system_configurations = @system_configurations.where(
        "(created_by_type = 'Admin' AND created_by_id IN (?)) OR created_by_id IS NULL",
        admin_ids
      )
    end
    
    # Search filter (by key) - case-insensitive
    if params[:search].present?
      search_term = "%#{params[:search].strip}%"
      # Use database-agnostic case-insensitive search
      if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
        @system_configurations = @system_configurations.where("key ILIKE ?", search_term)
      else
        @system_configurations = @system_configurations.where("LOWER(key) LIKE ?", search_term.downcase)
      end
    end
    
    # Additional filters
    @system_configurations = @system_configurations.by_category(params[:category]) if params[:category].present?
    @system_configurations = @system_configurations.by_creator_type(params[:creator_type]) if params[:creator_type].present?
    @system_configurations = @system_configurations.active if params[:active] == 'true'
    @system_configurations = @system_configurations.where(is_active: false) if params[:active] == 'false'
    
    # Filter by creator (current admin's configs)
    if params[:my_configs] == 'true'
      @system_configurations = @system_configurations.by_creator(current_admin)
    end
  end

  def show
  end

  def new
    @system_configuration = SystemConfiguration.new
  end

  def create
    service = System::ConfigurationCreationService.new(system_configuration_params, current_admin)
    service.call
    
    if service.success?
      redirect_to admin_system_configuration_path(service.system_configuration), notice: 'System Configuration created successfully.'
    else
      @system_configuration = service.system_configuration || SystemConfiguration.new(system_configuration_params)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    service = System::ConfigurationUpdateService.new(@system_configuration, system_configuration_params)
    service.call
    
    if service.success?
      redirect_to admin_system_configuration_path(@system_configuration), notice: 'System Configuration updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    service = System::ConfigurationDeletionService.new(@system_configuration)
    service.call
    
    if service.success?
      redirect_to admin_system_configurations_path, notice: 'System Configuration deleted successfully.'
    else
      redirect_to admin_system_configurations_path, alert: service.errors.first || 'Failed to delete system configuration'
    end
  end

  def activate
    service = System::ConfigurationActivationService.new(@system_configuration)
    service.call
    
    if service.success?
      redirect_to admin_system_configuration_path(@system_configuration), notice: 'System Configuration activated successfully.'
    else
      redirect_to admin_system_configuration_path(@system_configuration), alert: service.errors.first || 'Failed to activate system configuration'
    end
  end

  def deactivate
    service = System::ConfigurationDeactivationService.new(@system_configuration)
    service.call
    
    if service.success?
      redirect_to admin_system_configuration_path(@system_configuration), notice: 'System Configuration deactivated successfully.'
    else
      redirect_to admin_system_configuration_path(@system_configuration), alert: service.errors.first || 'Failed to deactivate system configuration'
    end
  end

  private

  def set_system_configuration
    @system_configuration = SystemConfiguration.find(params[:id])
    
    # Role-based access control: Ensure admin can only access configs from their role
    unless current_admin.super_admin?
      # Check if config was created by admin of same role or is system-created
      if @system_configuration.created_by_type == 'Admin' && @system_configuration.created_by_id.present?
        unless Admin.where(id: @system_configuration.created_by_id, role: current_admin.role).exists?
          redirect_to admin_system_configurations_path, alert: 'You do not have access to this configuration.'
          return
        end
      elsif @system_configuration.created_by_id.present?
        # Config created by different type (User, etc.) - deny access for non-super-admins
        redirect_to admin_system_configurations_path, alert: 'You do not have access to this configuration.'
        return
      end
      # System-created configs (created_by_id is nil) are accessible to all admins
    end
  end

  def system_configuration_params
    params.require(:system_configuration).permit(:key, :value, :value_type, :category, :description, :is_active)
  end

  def require_super_admin!
    # Allow super admins and other admins to access, but filter by role in index
    unless current_admin
      redirect_to admin_root_path, alert: 'Please log in to access admin panel.'
    end
  end
end

