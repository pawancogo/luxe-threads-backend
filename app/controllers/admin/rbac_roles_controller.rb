# frozen_string_literal: true

class Admin::RbacRolesController < Admin::BaseController
  before_action :require_super_admin!
  before_action :set_role, only: [:show, :edit, :update]
  
  def index
    @roles = RbacRole.for_admin.active.order(:priority, :name)
    @roles_by_type = @roles.group_by(&:role_type)
  end
  
  def show
    @permissions = @role.rbac_permissions.active.order(:category, :name)
    @permissions_by_category = @permissions.group_by(&:category)
    @assigned_admins = Admin.where(id: @role.admin_ids).where(is_active: true).distinct.limit(10)
  end
  
  def edit
    @all_permissions = RbacPermission.active.order(:category, :name)
    @permissions_by_category = @all_permissions.group_by(&:category)
    @current_permission_ids = @role.rbac_permission_ids
  end
  
  def update
    service = Rbac::RolePermissionsUpdateService.new(@role, params[:permission_ids])
    service.call
    
    if service.success?
      redirect_to admin_rbac_role_path(@role), notice: 'Role permissions updated successfully.'
    else
      flash.now[:alert] = "Error updating permissions: #{service.errors.join(', ')}"
      @all_permissions = RbacPermission.active.order(:category, :name)
      @permissions_by_category = @all_permissions.group_by(&:category)
      @current_permission_ids = @role.rbac_permission_ids
      render :edit, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_role
    @role = RbacRole.find(params[:id])
  end
end

