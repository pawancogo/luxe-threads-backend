# frozen_string_literal: true

module Api::V1::Admin
  class SettingsController < BaseController
    include AdminApiAuthorization
    
    before_action :require_super_admin!, only: [:create, :update, :destroy]
    
    # GET /api/v1/admin/settings
    def index
      service = SettingListingService.new(Setting.all, params)
      service.call
      
      if service.success?
        render_success(
          SettingSerializer.collection(service.settings),
          'Settings retrieved successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to retrieve settings')
      end
    end
    
    # GET /api/v1/admin/settings/:key
    def show
      service = SettingLookupService.new(params[:key])
      service.call
      
      if service.success?
        render_success(
          SettingSerializer.new(service.setting).as_json,
          'Setting retrieved successfully'
        )
      else
        render_not_found('Setting not found')
      end
    end
    
    # POST /api/v1/admin/settings
    def create
      service = Settings::CreationService.new(setting_params)
      service.call
      
      if service.success?
        log_admin_activity('create', 'Setting', service.setting.id, service.setting.previous_changes)
        render_created(
          SettingSerializer.new(service.setting).as_json,
          'Setting created successfully'
        )
      else
        render_validation_errors(service.errors, 'Setting creation failed')
      end
    end
    
    # PATCH /api/v1/admin/settings/:id
    def update
      @setting = Setting.find(params[:id])
      
      service = Settings::UpdateService.new(@setting, setting_params)
      service.call
      
      if service.success?
        log_admin_activity('update', 'Setting', @setting.id, @setting.previous_changes)
        render_success(
          SettingSerializer.new(@setting.reload).as_json,
          'Setting updated successfully'
        )
      else
        render_validation_errors(service.errors, 'Setting update failed')
      end
    end
    
    # DELETE /api/v1/admin/settings/:id
    def destroy
      @setting = Setting.find(params[:id])
      setting_id = @setting.id
      setting_key = @setting.key
      
      service = Settings::DeletionService.new(@setting)
      service.call
      
      if service.success?
        log_admin_activity('destroy', 'Setting', setting_id, { key: setting_key })
        render_no_content('Setting deleted successfully')
      else
        render_validation_errors(service.errors, 'Setting deletion failed')
      end
    end
    
    private
    
    def setting_params
      params.require(:setting).permit(:key, :value, :value_type, :category, :description, :is_public)
    end
    
    def require_super_admin!
      require_role!(['super_admin'])
    end
  end
end

