# frozen_string_literal: true

# RailsAdmin Delete Overrides
# Handles both single and bulk delete for User model with acts_as_paranoid
# Uses UserPermanentDeletionService for cleanup and permanent deletion

Rails.application.config.to_prepare do
  # Override single delete action
  RailsAdmin::Config::Actions::Delete.class_eval do
    register_instance_option :controller do
      proc do
        if request.delete? || params[:_method] == 'delete'
          # For User model, use permanent deletion service (hard delete)
          is_user_model = @abstract_model.model == User
          
          Rails.logger.info "RailsAdmin single delete: model=#{@abstract_model.model.name}, is_user_model=#{is_user_model}, responds_to_really_destroy=#{@object.respond_to?(:really_destroy!)}"
          
          if is_user_model
            # Reload user without scopes to ensure we get the actual record
            user = User.with_deleted.find(@object.id) if User.respond_to?(:with_deleted)
            user ||= User.find(@object.id)
            
            Rails.logger.info "RailsAdmin single delete: Using permanent deletion for User #{user.id}"
            begin
              UserPermanentDeletionService.delete(user)
              @auditing_adapter&.delete_object(user, @abstract_model, _current_user)
              flash[:success] = t('admin.flash.successful', name: @model_config.label, action: t('admin.actions.delete.done'))
            rescue ActiveRecord::InvalidForeignKey, ActiveRecord::StatementInvalid => e
              Rails.logger.error "Foreign key constraint error deleting User #{user.id}: #{e.message}"
              flash[:error] = t('admin.flash.error', name: @model_config.label, action: t('admin.actions.delete.done')) + ": Foreign key constraint failed"
            rescue StandardError => e
              Rails.logger.error "Error deleting User #{user.id}: #{e.class} - #{e.message}"
              Rails.logger.error e.backtrace.join("\n")
              flash[:error] = t('admin.flash.error', name: @model_config.label, action: t('admin.actions.delete.done')) + ": #{e.message}"
            end
            redirect_to index_path
          else
            # Default RailsAdmin behavior for other models
            @auditing_adapter&.delete_object(@object, @abstract_model, _current_user)
            if @object.destroy
              flash[:success] = t('admin.flash.successful', name: @model_config.label, action: t('admin.actions.delete.done'))
              redirect_to index_path
            else
              handle_save_error(:delete)
            end
          end
        else
          render @action.template_name
        end
      end
    end
  end

  # Override bulk delete action
  RailsAdmin::Config::Actions::BulkDelete.class_eval do
    register_instance_option :controller do
      proc do
        is_actual_deletion = request.delete? || params[:_method] == 'delete' || (request.post? && request.path.include?('bulk_ids'))
        
        if request.post? && !is_actual_deletion
          # Confirmation page
          @objects = list_entries(@model_config, :destroy)
          if @objects.blank?
            flash[:error] = t('admin.flash.error', name: pluralize(0, @model_config.label), action: t('admin.actions.delete.done'))
            redirect_to index_path
          else
            render @action.template_name
          end
        elsif is_actual_deletion
          # Actual deletion
          destroyed = []
          not_destroyed = []

          if params[:bulk_ids].present?
            @objects = list_entries(@model_config, :destroy)
            unless @objects.blank?
              is_user_model = @abstract_model.model == User
              
              @objects.each do |object|
                begin
                  if is_user_model
                    # Reload user without scopes to ensure we get the actual record
                    user = User.with_deleted.find(object.id) if User.respond_to?(:with_deleted)
                    user ||= User.find(object.id)
                    
                    Rails.logger.info "RailsAdmin bulk delete: Using permanent deletion for User #{user.id}"
                    UserPermanentDeletionService.delete(user)
                    destroyed << object
                  elsif object.destroy && object.errors.none?
                    destroyed << object
                  else
                    not_destroyed << object
                  end
                rescue ActiveRecord::InvalidForeignKey, ActiveRecord::StatementInvalid => e
                  Rails.logger.error "Foreign key constraint error deleting #{@abstract_model.model.name} #{object.id}: #{e.message}"
                  not_destroyed << object
                rescue StandardError => e
                  Rails.logger.error "Delete failed for #{@abstract_model.model.name} #{object.id}: #{e.class} - #{e.message}"
                  Rails.logger.error e.backtrace.join("\n")
                  not_destroyed << object
                end
              end

              # Audit deleted objects
              destroyed.each { |obj| @auditing_adapter&.delete_object(obj, @abstract_model, _current_user) }
            end
          end

          # Set flash messages
          if destroyed.empty? && not_destroyed.empty?
            flash[:error] = t('admin.flash.error', name: pluralize(0, @model_config.label), action: t('admin.actions.delete.done'))
          else
            flash[:success] = t('admin.flash.successful', name: pluralize(destroyed.count, @model_config.label), action: t('admin.actions.delete.done')) unless destroyed.empty?
            flash[:error] = t('admin.flash.error', name: pluralize(not_destroyed.count, @model_config.label), action: t('admin.actions.delete.done')) unless not_destroyed.empty?
          end
          redirect_to back_or_index
        end
      end
    end
  end
end

