# frozen_string_literal: true

module Api::V1::Admin
  class EmailTemplatesController < BaseController
    include AdminApiAuthorization
    
    before_action :require_super_admin!, only: [:create, :update, :destroy]
    before_action :set_email_template, only: [:show, :update, :destroy, :preview]
    
    # GET /api/v1/admin/email_templates
    def index
      @templates = EmailTemplate.order(:template_type)
      
      render_success(format_templates_data(@templates), 'Email templates retrieved successfully')
    end
    
    # GET /api/v1/admin/email_templates/:id
    def show
      render_success(format_template_detail_data(@email_template), 'Email template retrieved successfully')
    end
    
    # POST /api/v1/admin/email_templates
    def create
      @email_template = EmailTemplate.new(email_template_params)
      
      if @email_template.save
        log_admin_activity('create', 'EmailTemplate', @email_template.id, @email_template.previous_changes)
        render_created(format_template_detail_data(@email_template), 'Email template created successfully')
      else
        render_validation_errors(@email_template.errors.full_messages, 'Email template creation failed')
      end
    end
    
    # PATCH /api/v1/admin/email_templates/:id
    def update
      if @email_template.update(email_template_params)
        log_admin_activity('update', 'EmailTemplate', @email_template.id, @email_template.previous_changes)
        render_success(format_template_detail_data(@email_template), 'Email template updated successfully')
      else
        render_validation_errors(@email_template.errors.full_messages, 'Email template update failed')
      end
    end
    
    # DELETE /api/v1/admin/email_templates/:id
    def destroy
      template_id = @email_template.id
      template_type = @email_template.template_type
      
      if @email_template.destroy
        log_admin_activity('destroy', 'EmailTemplate', template_id, { template_type: template_type })
        render_no_content('Email template deleted successfully')
      else
        render_validation_errors(@email_template.errors.full_messages, 'Email template deletion failed')
      end
    end
    
    # POST /api/v1/admin/email_templates/:id/preview
    def preview
      preview_variables = params[:variables] || {}
      
      subject = @email_template.interpolate(@email_template.subject, preview_variables)
      body_html = @email_template.body_html ? @email_template.interpolate(@email_template.body_html, preview_variables) : nil
      body_text = @email_template.body_text ? @email_template.interpolate(@email_template.body_text, preview_variables) : nil
      
      render_success({
        subject: subject,
        body_html: body_html,
        body_text: body_text,
        from_email: @email_template.from_email,
        from_name: @email_template.from_name
      }, 'Email preview generated successfully')
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
    
    def format_templates_data(templates)
      templates.map { |t| format_template_detail_data(t) }
    end
    
    def format_template_detail_data(template)
      {
        id: template.id,
        template_type: template.template_type,
        subject: template.subject,
        body_html: template.body_html,
        body_text: template.body_text,
        from_email: template.from_email,
        from_name: template.from_name,
        is_active: template.is_active,
        variables: template.variables || {},
        description: template.description,
        created_at: template.created_at,
        updated_at: template.updated_at
      }
    end
  end
end

