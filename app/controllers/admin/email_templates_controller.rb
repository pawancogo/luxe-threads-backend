# frozen_string_literal: true

class Admin::EmailTemplatesController < Admin::BaseController
    before_action :require_super_admin!
    before_action :set_email_template, only: [:show, :edit, :update, :destroy, :preview]

    def index
      @templates = EmailTemplate.order(:template_type).page(params[:page])
    end

    def show
    end

    def new
      @template = EmailTemplate.new
    end

    def create
      service = EmailTemplates::CreationService.new(email_template_params)
      service.call
      
      if service.success?
        redirect_to admin_email_template_path(service.email_template), notice: 'Email template created successfully.'
      else
        @template = service.email_template || EmailTemplate.new(email_template_params)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      service = EmailTemplates::UpdateService.new(@template, email_template_params)
      service.call
      
      if service.success?
        redirect_to admin_email_template_path(@template), notice: 'Email template updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      service = EmailTemplates::DeletionService.new(@template)
      service.call
      
      if service.success?
        redirect_to admin_email_templates_path, notice: 'Email template deleted successfully.'
      else
        redirect_to admin_email_templates_path, alert: service.errors.first || 'Failed to delete email template'
      end
    end

    def preview
      service = EmailTemplatePreviewService.new(@template, params[:variables])
      service.call
      
      if service.success?
        @preview = service.preview_data
        render :preview
      else
        redirect_to admin_email_template_path(@template), alert: service.errors.first || 'Failed to generate preview'
      end
    end

    private

    def set_email_template
      @template = EmailTemplate.find(params[:id])
    end

    def email_template_params
      params.require(:email_template).permit(
        :template_type,
        :subject,
        :body_html,
        :body_text,
        :from_email,
        :from_name,
        :is_active,
        :description,
        variables: {}
      )
    end

    def require_super_admin!
      unless current_admin&.super_admin?
        redirect_to admin_root_path, alert: 'Super admin privileges required.'
      end
    end
  end

