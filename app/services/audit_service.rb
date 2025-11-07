class AuditService
  # Set the current user for PaperTrail
  def self.set_current_user(user)
    if user.is_a?(Admin)
      PaperTrail.request.whodunnit = "Admin:#{user.id}"
    elsif user.is_a?(User)
      # Suppliers are now Users with role='supplier'
      whodunnit_prefix = user.role == 'supplier' ? "Supplier" : "User"
      PaperTrail.request.whodunnit = "#{whodunnit_prefix}:#{user.id}"
    else
      PaperTrail.request.whodunnit = "System:Unknown"
    end
  end
  
  # Set additional metadata for audit trail
  def self.set_metadata(request)
    return unless request
    
    PaperTrail.request.controller_info = {
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      request_id: request.request_id,
      controller: request.controller_class&.name,
      action: request.action_name,
      params: request.params.except(:controller, :action, :password, :password_confirmation)
    }
  end
  
  # Get audit trail for a specific model
  def self.audit_trail_for(model)
    model.versions.order(created_at: :desc)
  end
  
  # Get audit trail for a specific user
  def self.audit_trail_for_user(user_id, user_type = 'User')
    Version.where(whodunnit: "#{user_type}:#{user_id}").order(created_at: :desc)
  end
  
  # Get recent activity across all models
  def self.recent_activity(limit = 50)
    Version.order(created_at: :desc).limit(limit)
  end
  
  # Get activity for a specific date range
  def self.activity_between(start_date, end_date)
    Version.where(created_at: start_date..end_date).order(created_at: :desc)
  end
  
  # Get activity by event type (create, update, destroy)
  def self.activity_by_event(event)
    Version.where(event: event).order(created_at: :desc)
  end
  
  # Get activity for a specific model type
  def self.activity_for_model(model_class)
    Version.where(item_type: model_class.name).order(created_at: :desc)
  end
  
  # Get activity by IP address
  def self.activity_by_ip(ip_address)
    Version.where("meta LIKE ?", "%#{ip_address}%").order(created_at: :desc)
  end
  
  # Get soft deleted records
  def self.soft_deleted_records(model_class)
    model_class.only_deleted
  end
  
  # Restore a soft deleted record
  def self.restore_record(record)
    return false unless record.respond_to?(:restore)
    record.restore
  end
  
  # Permanently delete a record (use with extreme caution)
  def self.permanently_delete(record)
    return false unless record.respond_to?(:really_destroy!)
    record.really_destroy!
  end
  
  # Get audit summary for a model
  def self.audit_summary(model)
    versions = model.versions
    {
      total_changes: versions.count,
      created_at: versions.where(event: 'create').first&.created_at,
      last_updated: versions.where(event: 'update').last&.created_at,
      last_modified_by: versions.last&.whodunnit,
      change_count: versions.where(event: 'update').count
    }
  end
  
  # Get audit trail with user information
  def self.audit_trail_with_users(model)
    versions = model.versions.includes(:item)
    versions.map do |version|
      {
        version: version,
        user_info: extract_user_info(version.whodunnit),
        changes: version.object_changes,
        metadata: version.meta
      }
    end
  end
  
  private
  
  def self.extract_user_info(whodunnit)
    return { type: 'Unknown', id: nil } unless whodunnit
    
    parts = whodunnit.split(':')
    return { type: 'System', id: parts[1] } if parts[0] == 'System'
    
    {
      type: parts[0],
      id: parts[1],
      user: find_user_by_type_and_id(parts[0], parts[1])
    }
  end
  
  def self.find_user_by_type_and_id(type, id)
    case type
    when 'Admin'
      Admin.find_by(id: id)
    when 'User'
      User.find_by(id: id)
    when 'Supplier'
      # Suppliers are now Users with role='supplier'
      User.where(role: 'supplier').find_by(id: id)
    else
      nil
    end
  end
end


