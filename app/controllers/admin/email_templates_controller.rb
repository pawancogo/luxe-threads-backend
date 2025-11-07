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
      @template = EmailTemplate.new(email_template_params)
      if @template.save
        redirect_to admin_email_template_path(@template), notice: 'Email template created successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @template.update(email_template_params)
        redirect_to admin_email_template_path(@template), notice: 'Email template updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @template.destroy
      redirect_to admin_email_templates_path, notice: 'Email template deleted successfully.'
    end

    def preview
      preview_variables = params[:variables] || {}
      @preview = {
        subject: @template.interpolate(@template.subject, preview_variables),
        body_html: @template.body_html ? @template.interpolate(@template.body_html, preview_variables) : nil,
        body_text: @template.body_text ? @template.interpolate(@template.body_text, preview_variables) : nil,
        from_email: @template.from_email,
        from_name: @template.from_name
      }
      render :preview
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

