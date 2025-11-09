# frozen_string_literal: true

class Admin::NavigationItemsController < Admin::BaseController
  before_action :require_super_admin!
  before_action :set_navigation_item, only: [:show, :edit, :update, :destroy]
  
  def index
    @navigation_items = NavigationItem.all.ordered
    @sections = @navigation_items.group_by(&:section)
  end
  
  def show
  end
  
  def new
    @navigation_item = NavigationItem.new
    @available_permissions = RbacPermission.active.pluck(:slug).sort
  end
  
  def create
    @navigation_item = NavigationItem.new(navigation_item_params)
    @navigation_item.required_permissions_array = filter_permissions_array(params[:navigation_item][:required_permissions_array])
    @navigation_item.view_permissions_array = filter_permissions_array(params[:navigation_item][:view_permissions_array])
    @navigation_item.create_permissions_array = filter_permissions_array(params[:navigation_item][:create_permissions_array])
    @navigation_item.edit_permissions_array = filter_permissions_array(params[:navigation_item][:edit_permissions_array])
    @navigation_item.delete_permissions_array = filter_permissions_array(params[:navigation_item][:delete_permissions_array])
    
    if @navigation_item.save
      redirect_to admin_navigation_items_path, notice: 'Navigation item created successfully.'
    else
      @available_permissions = RbacPermission.active.pluck(:slug).sort
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @available_permissions = RbacPermission.active.pluck(:slug).sort
  end
  
  def update
    @navigation_item.assign_attributes(navigation_item_params)
    @navigation_item.required_permissions_array = filter_permissions_array(params[:navigation_item][:required_permissions_array])
    @navigation_item.view_permissions_array = filter_permissions_array(params[:navigation_item][:view_permissions_array])
    @navigation_item.create_permissions_array = filter_permissions_array(params[:navigation_item][:create_permissions_array])
    @navigation_item.edit_permissions_array = filter_permissions_array(params[:navigation_item][:edit_permissions_array])
    @navigation_item.delete_permissions_array = filter_permissions_array(params[:navigation_item][:delete_permissions_array])
    
    if @navigation_item.save
      redirect_to admin_navigation_items_path, notice: 'Navigation item updated successfully.'
    else
      @available_permissions = RbacPermission.active.pluck(:slug).sort
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @navigation_item.is_system
      redirect_to admin_navigation_items_path, alert: 'System navigation items cannot be deleted.'
    else
      @navigation_item.destroy
      redirect_to admin_navigation_items_path, notice: 'Navigation item deleted successfully.'
    end
  end
  
  private
  
  def set_navigation_item
    @navigation_item = NavigationItem.find(params[:id])
  end
  
  def filter_permissions_array(array_param)
    return [] unless array_param
    array_param.reject(&:blank?)
  end
  
  def navigation_item_params
    params.require(:navigation_item).permit(
      :key, :label, :icon, :path_method, :section, :controller_name,
      :require_super_admin, :always_visible, :is_active,
      :can_view, :can_create, :can_edit, :can_delete,
      :display_order, :description
    )
  end
end

