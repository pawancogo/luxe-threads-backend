# frozen_string_literal: true

module Api::V1::Admin
  class EmailTemplatesController < BaseController
    include AdminApiAuthorization
    
    before_action :require_super_admin!, only: [:create, :update, :destroy]
    before_action :set_email_template, only: [:show, :update, :destroy, :preview]
    
    # GET /api/v1/admin/email_templates
    def index
      service = EmailTemplateListingService.new(EmailTemplate.all, params)
      service.call
      
      if service.success?
        render_success(
          EmailTemplateSerializer.collection(service.templates),
          'Email templates retrieved successfully'
        )
      else
        render_validation_errors(service.errors, 'Failed to retrieve email templates')
      end
    end
    
    # GET /api/v1/admin/email_templates/:id
    def show
      render_success(
        EmailTemplateSerializer.new(@email_template).as_json,
        'Email template retrieved successfully'
      )
    end
    
    # POST /api/v1/admin/email_templates
    def create
      service = EmailTemplates::CreationService.new(email_template_params)
      service.call
      
      if service.success?
        log_admin_activity('create', 'EmailTemplate', service.email_template.id, service.email_template.previous_changes)
        render_created(
          EmailTemplateSerializer.new(service.email_template).as_json,
          'Email template created successfully'
        )
      else
        render_validation_errors(service.errors, 'Email template creation failed')
      end
    end
    
    # PATCH /api/v1/admin/email_templates/:id
    def update
      service = EmailTemplates::UpdateService.new(@email_template, email_template_params)
      service.call
      
      if service.success?
        log_admin_activity('update', 'EmailTemplate', @email_template.id, @email_template.previous_changes)
        render_success(
          EmailTemplateSerializer.new(@email_template.reload).as_json,
          'Email template updated successfully'
        )
      else
        render_validation_errors(service.errors, 'Email template update failed')
      end
    end
    
    # DELETE /api/v1/admin/email_templates/:id
    def destroy
      template_id = @email_template.id
      template_type = @email_template.template_type
      
      service = EmailTemplates::DeletionService.new(@email_template)
      service.call
      
      if service.success?
        log_admin_activity('destroy', 'EmailTemplate', template_id, { template_type: template_type })
        render_no_content('Email template deleted successfully')
      else
        render_validation_errors(service.errors, 'Email template deletion failed')
      end
    end
    
    # POST /api/v1/admin/email_templates/:id/preview
    def preview
      service = EmailTemplatePreviewService.new(@email_template, params[:variables])
      service.call
      
      if service.success?
        render_success(service.preview_data, 'Email preview generated successfully')
      else
        render_error(service.errors.first || 'Failed to generate preview', :internal_server_error)
      end
    end
    
    private
    
    def set_email_template
      @email_template = EmailTemplate.find(params[:id])
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
      require_role!(['super_admin'])
    end
  end
end

