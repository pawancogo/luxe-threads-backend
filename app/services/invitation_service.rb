# frozen_string_literal: true

# Service for handling invitations (Admin and Supplier)
class InvitationService
  INVITATION_EXPIRY_DAYS = 7
  INVITATION_STATUSES = {
    pending: 'pending',
    accepted: 'accepted',
    expired: 'expired',
    cancelled: 'cancelled'
  }.freeze

  attr_reader :invitee, :inviter, :errors

  def initialize(invitee, inviter = nil)
    @invitee = invitee
    @inviter = inviter
    @errors = []
  end

  # Send invitation for admin
  def send_admin_invitation(role)
    return false unless validate_admin_invitation(role)

    ActiveRecord::Base.transaction do
      generate_invitation_token
      set_invitation_fields(role)
      
      unless @invitee.save(validate: false) # Skip password validation for pending invitations
        @errors = @invitee.errors.full_messages
        raise ActiveRecord::RecordInvalid.new(@invitee)
      end
      
      send_invitation_email('admin', role)
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors = @invitee.errors.full_messages
    Rails.logger.error "Admin invitation failed: #{e.message} - #{@errors.join(', ')}"
    false
  rescue StandardError => e
    @errors << "An unexpected error occurred: #{e.message}"
    Rails.logger.error "Admin invitation failed: #{e.message} - #{e.backtrace.first(5).join("\n")}"
    false
  end

  # Send invitation for supplier
  # Options:
  #   - role: supplier role (default: 'supplier')
  #   - supplier_profile_id: if provided, creates child supplier (SupplierAccountUser)
  #   - account_role: role within the supplier account (for child suppliers)
  #   - permissions: hash of permissions for child suppliers
  def send_supplier_invitation(role = 'supplier', options = {})
    return false unless validate_supplier_invitation(role)

    supplier_profile_id = options[:supplier_profile_id]
    account_role = options[:account_role] || 'staff'
    permissions = options[:permissions] || {}

    ActiveRecord::Base.transaction do
      generate_invitation_token
      set_invitation_fields_for_user(role)
      
      unless @invitee.save(validate: false)
        @errors = @invitee.errors.full_messages
        raise ActiveRecord::RecordInvalid.new(@invitee)
      end

      # If supplier_profile_id is provided, create child supplier (SupplierAccountUser)
      if supplier_profile_id.present?
        supplier_profile = SupplierProfile.find_by(id: supplier_profile_id)
        unless supplier_profile
          @errors << 'Supplier profile not found'
          raise ActiveRecord::RecordInvalid.new(@invitee)
        end

        # Check if user already exists in this supplier account
        existing_account_user = SupplierAccountUser.find_by(
          supplier_profile_id: supplier_profile_id,
          user_id: @invitee.id
        )

        if existing_account_user
          @errors << 'User is already part of this supplier account'
          raise ActiveRecord::RecordInvalid.new(@invitee)
        end

        # Validate that inviter is owner or admin
        # Admin can always invite
        if @inviter.is_a?(Admin)
          # Admin can invite - no validation needed
        elsif @inviter.is_a?(User)
          # If inviter is a User, they must be the owner (parent supplier)
          inviter_account_user = SupplierAccountUser.find_by(
            supplier_profile: supplier_profile,
            user: @inviter
          )
          
          unless inviter_account_user&.owner?
            @errors << 'Only the parent supplier (owner) or admin can invite child suppliers'
            raise ActiveRecord::RecordInvalid.new(@invitee)
          end
        end

        # Prevent creating another owner (only one owner per account)
        if account_role == 'owner'
          existing_owner = SupplierAccountUser.find_by(
            supplier_profile: supplier_profile,
            role: 'owner'
          )
          
          if existing_owner
            @errors << 'There can only be one owner per supplier account'
            raise ActiveRecord::RecordInvalid.new(@invitee)
          end
        end

        # Create SupplierAccountUser with pending invitation
        # Note: invited_by can be nil when Admin invites (foreign key allows NULL)
        supplier_account_user = SupplierAccountUser.new(
          supplier_profile: supplier_profile,
          user: @invitee,
          role: account_role,
          status: 'pending_invitation',
          can_manage_products: permissions[:can_manage_products] || false,
          can_manage_orders: permissions[:can_manage_orders] || false,
          can_view_financials: permissions[:can_view_financials] || false,
          can_manage_users: permissions[:can_manage_users] || false,
          can_manage_settings: permissions[:can_manage_settings] || false,
          can_view_analytics: permissions[:can_view_analytics] || false
        )
        
        # Only set invited_by if inviter is a User (Admin invitations don't set this)
        supplier_account_user.invited_by = @inviter if @inviter.is_a?(User)
        
        unless supplier_account_user.save
          @errors = supplier_account_user.errors.full_messages
          raise ActiveRecord::RecordInvalid.new(supplier_account_user)
        end
      end

      send_invitation_email('supplier', role)
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors = @invitee.errors.full_messages
    Rails.logger.error "Supplier invitation failed: #{e.message} - #{@errors.join(', ')}"
    false
  rescue StandardError => e
    @errors << "An unexpected error occurred: #{e.message}"
    Rails.logger.error "Supplier invitation failed: #{e.message} - #{e.backtrace.first(5).join("\n")}"
    false
  end

  # Accept invitation and complete registration
  def accept_invitation(params)
    return false unless valid_invitation_token?(params[:token])
    return false if invitation_expired?
    return false if invitation_already_accepted?

    ActiveRecord::Base.transaction do
      update_invitee_details(params)
      mark_invitation_accepted
      
      # Check if this is a child supplier (invited by another supplier)
      is_child_supplier = check_if_child_supplier
      
      if is_child_supplier
        # Child suppliers: activate immediately, no admin approval needed
        activate_child_supplier
      else
        # Parent suppliers: need admin approval (supplier_profile.verified = false)
        # is_active is already set to true in update_invitee_details
        
        # Create SupplierAccountUser with owner role for parent supplier
        if @invitee.role == 'supplier' && @invitee.supplier_profile.present?
          create_parent_supplier_account_user
        end
      end
      
      unless @invitee.save
        @errors = @invitee.errors.full_messages
        raise ActiveRecord::RecordInvalid.new(@invitee)
      end
      
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    @errors = @invitee.errors.full_messages
    Rails.logger.error "Invitation acceptance failed: #{e.message}"
    false
  rescue StandardError => e
    @errors << "An unexpected error occurred: #{e.message}"
    Rails.logger.error "Invitation acceptance failed: #{e.message} - #{e.backtrace.first(5).join("\n")}"
    false
  end

  # Resend invitation
  def resend_invitation
    return false unless invitation_pending?
    return false if invitation_expired?

    generate_invitation_token
    @invitee.invitation_sent_at = Time.current
    @invitee.invitation_expires_at = INVITATION_EXPIRY_DAYS.days.from_now

    if @invitee.save
      invitation_type = @invitee.is_a?(Admin) ? 'admin' : 'supplier'
      role = @invitee.is_a?(Admin) ? @invitee.role : @invitee.invitation_role
      send_invitation_email(invitation_type, role)
      true
    else
      @errors = @invitee.errors.full_messages
      false
    end
  end

  # Cancel invitation
  def cancel_invitation
    return false unless invitation_pending?

    @invitee.update(
      invitation_status: INVITATION_STATUSES[:cancelled],
      invitation_token: nil
    )
  end

  # Check if invitation is valid
  def valid_invitation_token?(token)
    return false if token.blank?
    return false unless @invitee.invitation_token.present?
    
    ActiveSupport::SecurityUtils.secure_compare(
      @invitee.invitation_token,
      token
    )
  end

  def invitation_expired?
    return false unless @invitee.invitation_expires_at.present?
    @invitee.invitation_expires_at < Time.current
  end

  def invitation_pending?
    @invitee.invitation_status == INVITATION_STATUSES[:pending]
  end

  def invitation_already_accepted?
    @invitee.invitation_status == INVITATION_STATUSES[:accepted] ||
      @invitee.invitation_accepted_at.present?
  end

  private

  def validate_admin_invitation(role)
    @errors = []
    
    unless @invitee.is_a?(Admin)
      @errors << 'Invitee must be an Admin'
      return false
    end

    if @invitee.email.blank?
      @errors << 'Email is required'
      return false
    end

    unless Admin.roles.key?(role)
      @errors << 'Invalid admin role'
      return false
    end

    existing_admin = Admin.find_by(email: @invitee.email)
    if existing_admin && @invitee.new_record? && !existing_admin.pending_invitation?
      @errors << 'Admin with this email already exists'
      return false
    end
    
    # If admin exists and is pending invitation, use that record
    if existing_admin && existing_admin.pending_invitation?
      @invitee = existing_admin
    end

    true
  end

  def validate_supplier_invitation(role)
    @errors = []
    
    unless @invitee.is_a?(User)
      @errors << 'Invitee must be a User'
      return false
    end

    if @invitee.email.blank?
      @errors << 'Email is required'
      return false
    end

    if role != 'supplier' && !%w[supplier_manager supplier_staff].include?(role)
      @errors << 'Invalid supplier role'
      return false
    end

    existing_user = User.find_by(email: @invitee.email)
    if existing_user && @invitee.new_record? && !existing_user.pending_invitation?
      @errors << 'User with this email already exists'
      return false
    end
    
    # If user exists and is pending invitation, use that record
    if existing_user && existing_user.pending_invitation?
      @invitee = existing_user
    end

    true
  end

  def generate_invitation_token
    loop do
      token = SecureRandom.urlsafe_base64(32)
      unless Admin.exists?(invitation_token: token) || User.exists?(invitation_token: token)
        @invitee.invitation_token = token
        break
      end
    end
  end

  def set_invitation_fields(role)
    @invitee.role = role
    @invitee.invitation_status = INVITATION_STATUSES[:pending]
    @invitee.invitation_sent_at = Time.current
    @invitee.invitation_expires_at = INVITATION_EXPIRY_DAYS.days.from_now
    # Only set invited_by_id if inviter is a User (foreign key constraint requires User, not Admin)
    @invitee.invited_by_id = @inviter.is_a?(User) ? @inviter.id : nil
    @invitee.is_active = false # Activate after invitation acceptance
  end

  def set_invitation_fields_for_user(role)
    @invitee.role = 'supplier' # Base role
    @invitee.invitation_role = role # Specific supplier role
    @invitee.invitation_status = INVITATION_STATUSES[:pending]
    @invitee.invitation_sent_at = Time.current
    @invitee.invitation_expires_at = INVITATION_EXPIRY_DAYS.days.from_now
    # Only set invited_by_id if inviter is a User (foreign key constraint requires User, not Admin)
    @invitee.invited_by_id = @inviter.is_a?(User) ? @inviter.id : nil
    @invitee.is_active = false # Activate after invitation acceptance
  end

  def update_invitee_details(params)
    if @invitee.is_a?(Admin)
      @invitee.first_name = params[:first_name]
      @invitee.last_name = params[:last_name]
      @invitee.phone_number = params[:phone_number]
      @invitee.password = params[:password]
      @invitee.password_confirmation = params[:password_confirmation]
      @invitee.is_active = true # Admins are activated immediately
    else
      @invitee.first_name = params[:first_name]
      @invitee.last_name = params[:last_name]
      @invitee.phone_number = params[:phone_number]
      @invitee.password = params[:password]
      @invitee.password_confirmation = params[:password_confirmation]
      
      # Check if this is a child supplier (has SupplierAccountUser with pending_invitation)
      is_child = check_if_child_supplier
      
      if is_child
        # Child suppliers: activated immediately, no supplier profile needed (they join existing)
        @invitee.is_active = true
      else
        # Parent suppliers: create supplier profile (required for parent suppliers)
        if @invitee.role == 'supplier'
          if params[:supplier_profile_attributes].present?
            # Create profile with provided attributes
            profile = @invitee.build_supplier_profile(params[:supplier_profile_attributes])
          else
            # Create minimal profile if not provided (parent supplier must have a profile)
            profile = @invitee.build_supplier_profile
          end
          
          profile.owner_id = @invitee.id # Set owner
          profile.user_id = @invitee.id # Legacy compatibility
          # Parent suppliers need admin approval
          profile.verified = false unless profile.persisted?
        end
        
        # Parent suppliers: activated but need profile verification
        @invitee.is_active = true
      end
    end
  end

  def mark_invitation_accepted
    @invitee.invitation_status = INVITATION_STATUSES[:accepted]
    @invitee.invitation_accepted_at = Time.current
    @invitee.invitation_token = nil # Clear token after acceptance
  end

  def send_invitation_email(type, role)
    invitation_url = build_invitation_url(type)
    
    case type
    when 'admin'
      InvitationMailer.admin_invitation(@invitee, invitation_url, @inviter).deliver_now
    when 'supplier'
      InvitationMailer.supplier_invitation(@invitee, invitation_url, @inviter, role).deliver_now
    end
  end

  def build_invitation_url(type)
    protocol = Rails.env.production? ? 'https' : 'http'
    
    if type == 'admin'
      # Admin invitations point to backend admin panel
      default_options = Rails.application.config.action_mailer.default_url_options
      host = default_options[:host] || 'localhost'
      port = default_options[:port] || 3000
      
      base_url = if Rails.env.production?
        host
      else
        "#{host}:#{port}"
      end
      
      "#{protocol}://#{base_url}/admin/invitations/accept?token=#{@invitee.invitation_token}"
    else
      # Supplier invitations point to frontend (suppliers and customers use FE)
      frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:8080')
      # Remove protocol if present (we'll add it based on environment)
      frontend_host = frontend_url.gsub(/^https?:\/\//, '')
      
      # Extract port if present in FRONTEND_URL
      if frontend_host.include?(':')
        base_url = frontend_host
      else
        # If no port in FRONTEND_URL, add default port for development
        base_url = Rails.env.production? ? frontend_host : "#{frontend_host}:8080"
      end
      
      "#{protocol}://#{base_url}/supplier/invitations/accept?token=#{@invitee.invitation_token}"
    end
  end

  # Check if this supplier is a child supplier (invited by another supplier)
  def check_if_child_supplier
    return false unless @invitee.is_a?(User) && @invitee.role == 'supplier'
    
    # Check if there's a SupplierAccountUser with pending_invitation status
    @invitee.supplier_account_users.exists?(status: 'pending_invitation')
  end

  # Activate child supplier immediately (no admin approval needed)
  def activate_child_supplier
    @invitee.is_active = true
    
    # Find and activate the SupplierAccountUser
    supplier_account_user = @invitee.supplier_account_users.find_by(status: 'pending_invitation')
    
    if supplier_account_user
      supplier_account_user.accept_invitation!
      
      # Ensure the supplier profile is active (child suppliers don't need verification)
      supplier_profile = supplier_account_user.supplier_profile
      if supplier_profile
        supplier_profile.update(verified: true, is_active: true) unless supplier_profile.verified?
      end
    end
  end

  # Create SupplierAccountUser for parent supplier with owner role
  def create_parent_supplier_account_user
    profile = @invitee.supplier_profile
    return unless profile.present?
    
    # Ensure owner_id is set
    profile.update!(owner_id: @invitee.id, user_id: @invitee.id) if profile.owner_id.blank?
    
    # Check if SupplierAccountUser already exists
    existing_account_user = SupplierAccountUser.find_by(
      supplier_profile: profile,
      user: @invitee
    )
    
    return if existing_account_user.present?
    
    # Create SupplierAccountUser with owner role for parent supplier
    SupplierAccountUser.create!(
      supplier_profile: profile,
      user: @invitee,
      role: 'owner',
      status: 'active',
      can_manage_products: true,
      can_manage_orders: true,
      can_view_financials: true,
      can_manage_users: true,
      can_manage_settings: true,
      can_view_analytics: true,
      accepted_at: Time.current
    )
  end
end

