# frozen_string_literal: true

module Api::V1::Admin
  class SettingsController < BaseController
    include AdminApiAuthorization
    
    before_action :require_super_admin!, only: [:create, :update, :destroy]
    
    # GET /api/v1/admin/settings
    def index
      category = params[:category]
      @settings = category.present? ? Setting.by_category(category) : Setting.all
      @settings = @settings.order(:category, :key)
      
      render_success(format_settings_data(@settings), 'Settings retrieved successfully')
    end
    
    # GET /api/v1/admin/settings/:key
    def show
      @setting = Setting.find_by(key: params[:key])
      
      if @setting
        render_success(format_setting_detail_data(@setting), 'Setting retrieved successfully')
      else
        render_not_found('Setting not found')
      end
    end
    
    # POST /api/v1/admin/settings
    def create
      @setting = Setting.new(setting_params)
      
      if @setting.save
        log_admin_activity('create', 'Setting', @setting.id, @setting.previous_changes)
        render_created(format_setting_detail_data(@setting), 'Setting created successfully')
      else
        render_validation_errors(@setting.errors.full_messages, 'Setting creation failed')
      end
    end
    
    # PATCH /api/v1/admin/settings/:id
    def update
      @setting = Setting.find(params[:id])
      
      if @setting.update(setting_params)
        log_admin_activity('update', 'Setting', @setting.id, @setting.previous_changes)
        render_success(format_setting_detail_data(@setting), 'Setting updated successfully')
      else
        render_validation_errors(@setting.errors.full_messages, 'Setting update failed')
      end
    end
    
    # DELETE /api/v1/admin/settings/:id
    def destroy
      @setting = Setting.find(params[:id])
      setting_id = @setting.id
      setting_key = @setting.key
      
      if @setting.destroy
        log_admin_activity('destroy', 'Setting', setting_id, { key: setting_key })
        render_no_content('Setting deleted successfully')
      else
        render_validation_errors(@setting.errors.full_messages, 'Setting deletion failed')
      end
    end
    
    private
    
    def setting_params
      params.require(:setting).permit(:key, :value, :value_type, :category, :description, :is_public)
    end
    
    def require_super_admin!
      require_role!(['super_admin'])
    end
    
    def format_settings_data(settings)
      settings.map { |s| format_setting_detail_data(s) }
    end
    
    def format_setting_detail_data(setting)
      {
        id: setting.id,
        key: setting.key,
        value: setting.cast_value,
        value_type: setting.value_type,
        category: setting.category,
        description: setting.description,
        is_public: setting.is_public,
        created_at: setting.created_at,
        updated_at: setting.updated_at
      }
    end
  end
end

