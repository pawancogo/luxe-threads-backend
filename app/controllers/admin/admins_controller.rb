class Admin::AdminsController < Admin::BaseController
  include StatusManageable
  
  before_action :require_super_admin!, except: [:show, :edit, :update]
  before_action :set_admin, only: [:show, :edit, :update, :destroy, :block, :unblock, :update_status, :resend_invitation]
  before_action :ensure_own_profile_or_super_admin, only: [:show]
  before_action :ensure_own_profile_or_super_admin_for_edit, only: [:edit, :update]

  def index
    search_params = params.except(:controller, :action).permit(:search, :per_page, :page, :role, :is_active, :is_blocked, :date_range, :min, :max)
    
    @admins = Admin._search(search_params).order(:role, :first_name)
    
    # Merge filters (this will include aggregations)
    begin
      filter_aggs = @admins.filter_with_aggs if @admins.respond_to?(:filter_with_aggs)
      @filters.merge!(filter_aggs) if filter_aggs.present?
    rescue => e
      Rails.logger.error "Error merging filters: #{e.message}"
      @filters ||= { search: [nil] }
    end
  end

  def show
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)
    
    if @admin.save
      redirect_to admin_admins_path, notice: 'Admin created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Invitation flow
  def invite
    @admin = Admin.new
  end

  def send_invitation
    @admin = Admin.find_or_initialize_by(email: params[:admin][:email])
    role = params[:admin][:role]
    
    service = InvitationService.new(@admin, current_admin)
    
    if service.send_admin_invitation(role)
      redirect_to admin_admins_path, notice: "Invitation sent to #{@admin.email} successfully."
    else
      @errors = service.errors
      @admin = Admin.new(email: params[:admin][:email]) # Reset for form
      render :invite, status: :unprocessable_entity
    end
  end

  def resend_invitation
    service = InvitationService.new(@admin, current_admin)
    
    if service.resend_invitation
      redirect_to admin_admins_path, notice: "Invitation resent to #{@admin.email}."
    else
      redirect_to admin_admins_path, alert: "Failed to resend invitation: #{service.errors.join(', ')}"
    end
  end

  def edit
  end

  def update
    if @admin.update(admin_params)
      # Redirect to own profile if editing own account, otherwise to admins list
      if @admin == current_admin
        redirect_to admin_admin_path(@admin), notice: 'Profile updated successfully.'
      else
        redirect_to admin_admins_path, notice: 'Admin updated successfully.'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Prevent super admin from deleting themselves
    if @admin == current_admin
      redirect_to admin_admins_path, alert: 'You cannot delete your own account.'
      return
    end
    
    @admin.destroy
    redirect_to admin_admins_path, notice: 'Admin deleted successfully.'
  end

  def block
    # Prevent super admin from blocking themselves
    if @admin == current_admin
      redirect_back(fallback_location: admin_admins_path, alert: 'You cannot block your own account.')
      return
    end
    
    if @admin.block!
      # Log admin activity for blocking
      AdminActivity.log_activity(
        current_admin,
        'block',
        'Admin',
        @admin.id,
        {
          description: "Blocked admin: #{@admin.full_name} (#{@admin.email})",
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        }
      )
      
      redirect_back(fallback_location: admin_admins_path, notice: "#{@admin.full_name} has been blocked successfully. All their active sessions have been terminated.")
    else
      redirect_back(fallback_location: admin_admins_path, alert: 'Failed to block admin.')
    end
  end

  def unblock
    if @admin.unblock!
      redirect_back(fallback_location: admin_admins_path, notice: "#{@admin.full_name} has been unblocked successfully.")
    else
      redirect_back(fallback_location: admin_admins_path, alert: 'Failed to unblock admin.')
    end
  end

  # Uses StatusManageable concern
  def update_status
    super
  end

  private

  def set_admin
    @admin = Admin.find(params[:id])
  end

  def admin_params
    permitted = [:first_name, :last_name, :email, :phone_number, :password, :password_confirmation]
    # Only super admins can change role when editing other admins
    # Admins cannot change their own role
    permitted << :role if current_admin&.super_admin? && @admin != current_admin
    params.require(:admin).permit(*permitted)
  end

  # StatusManageable implementation
  def get_status_resource
    @admin
  end

  def activate_resource(resource)
    resource.update(is_active: true)
  end

  def deactivate_resource(resource)
    # When admin is deactivated, reset email verification status and require re-verification via OTP
    if resource.update(is_active: false, email_verified: false)
      # Always send verification email to require re-verification for reactivation
      EmailVerificationService.new(resource).send_verification_email unless resource.email_verifications.pending.active.exists?
      true
    else
      false
    end
  end

  def prevent_self_modification?(resource)
    resource == current_admin
  end

  def status_success_path(resource)
    admin_admin_path(resource)
  end

  def status_error_path
    admin_admin_path(@admin)
  end
  
  def ensure_own_profile_or_super_admin
    # Allow admins to view their own profile, or super admins to view any profile
    unless @admin == current_admin || current_admin&.super_admin?
      redirect_to admin_root_path, alert: 'You do not have permission to view this profile.'
    end
  end
  
  def ensure_own_profile_or_super_admin_for_edit
    # Allow admins to edit their own profile, or super admins to edit any profile
    unless @admin == current_admin || current_admin&.super_admin?
      redirect_to admin_root_path, alert: 'You do not have permission to edit this profile.'
    end
  end
end


