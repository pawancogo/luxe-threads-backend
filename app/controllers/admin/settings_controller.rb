# frozen_string_literal: true

class Admin::SettingsController < Admin::BaseController
    before_action :require_super_admin!
    before_action :set_setting, only: [:show, :edit, :update, :destroy]

    def index
      @settings = Setting.order(:category, :key).page(params[:page])
      @settings = @settings.by_category(params[:category]) if params[:category].present?
    end

    def show
    end

    def new
      @setting = Setting.new
    end

    def create
      @setting = Setting.new(setting_params)
      if @setting.save
        redirect_to admin_setting_path(@setting), notice: 'Setting created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @setting.update(setting_params)
        redirect_to admin_setting_path(@setting), notice: 'Setting updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @setting.destroy
      redirect_to admin_settings_path, notice: 'Setting deleted successfully.'
    end

    private

    def set_setting
      @setting = Setting.find(params[:id])
    end

    def setting_params
      params.require(:setting).permit(:key, :value, :value_type, :category, :description, :is_public)
    end

    def require_super_admin!
      unless current_admin&.super_admin?
        redirect_to admin_root_path, alert: 'Super admin privileges required.'
      end
    end
  end

