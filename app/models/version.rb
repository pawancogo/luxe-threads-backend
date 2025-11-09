class Version < PaperTrail::Version
  extend SearchManager
  
  # Search manager configuration
  search_manager on: [:item_type, :event, :whodunnit], aggs_on: [:item_type, :event, :whodunnit]
  
  # Add scopes for common queries
  scope :by_user, ->(user_id) { where(whodunnit: "User:#{user_id}") }
  scope :by_admin, ->(admin_id) { where(whodunnit: "Admin:#{admin_id}") }
  scope :by_supplier, ->(supplier_id) { where(whodunnit: "Supplier:#{supplier_id}") }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_model, ->(model_class) { where(item_type: model_class.name) }
  scope :by_event, ->(event) { where(event: event) }
  scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  
  # Helper methods
  def user_type
    return 'Admin' if whodunnit&.start_with?('Admin:')
    return 'User' if whodunnit&.start_with?('User:')
    return 'Supplier' if whodunnit&.start_with?('Supplier:')
    return 'System' if whodunnit&.start_with?('System:')
    'Unknown'
  end
  
  def user_id
    return whodunnit.split(':').last if whodunnit&.include?(':')
    nil
  end
  
  def ip_address
    return self[:ip_address] if self[:ip_address].present?
    # Try to get from meta if available
    begin
      meta_data = meta
      return meta_data['ip_address'] if meta_data.is_a?(Hash) && meta_data['ip_address']
    rescue
      # meta column might not exist
    end
    nil
  end
  
  def user_agent
    return self[:user_agent] if self[:user_agent].present?
    # Try to get from meta if available
    begin
      meta_data = meta
      return meta_data['user_agent'] if meta_data.is_a?(Hash) && meta_data['user_agent']
    rescue
      # meta column might not exist
    end
    nil
  end
  
  def controller_action
    begin
      meta_data = meta
      return "#{meta_data['controller']}##{meta_data['action']}" if meta_data.is_a?(Hash) && meta_data['controller'] && meta_data['action']
    rescue
      # meta column might not exist
    end
    nil
  end
  
  def request_id
    begin
      meta_data = meta
      return meta_data['request_id'] if meta_data.is_a?(Hash) && meta_data['request_id']
    rescue
      # meta column might not exist
    end
    nil
  end
  
  def source
    begin
      meta_data = meta
      return meta_data['source'] if meta_data.is_a?(Hash) && meta_data['source']
    rescue
      # meta column might not exist
    end
    
    # Infer from controller_action
    if controller_action
      if controller_action.include?('Admin::')
        'Admin Panel'
      elsif controller_action.include?('Api::')
        'API'
      else
        'Web'
      end
    elsif whodunnit.blank? || whodunnit == 'System:Console'
      'Console/Rails Console'
    else
      'Unknown'
    end
  end
  
  def actioned_by_name
    user_obj = user_object
    return user_obj.full_name if user_obj.respond_to?(:full_name)
    return user_obj.email if user_obj.respond_to?(:email)
    return user_obj.name if user_obj.respond_to?(:name)
    return "#{user_type} ##{user_id}" if user_id
    whodunnit || 'System'
  end
  
  def actioned_by_email
    user_obj = user_object
    return user_obj.email if user_obj.respond_to?(:email)
    nil
  end
  
  def actioned_on_name
    item_obj = item_object
    return item_obj.name if item_obj.respond_to?(:name)
    return item_obj.full_name if item_obj.respond_to?(:full_name)
    return item_obj.email if item_obj.respond_to?(:email)
    return item_obj.title if item_obj.respond_to?(:title)
    "#{item_type} ##{item_id}"
  end
  
  def actioned_at
    created_at.strftime('%B %d, %Y at %I:%M %p')
  end
  
  # Get the actual user object
  def user_object
    return nil unless user_id
    
    case user_type
    when 'Admin'
      Admin.find_by(id: user_id)
    when 'User'
      User.find_by(id: user_id)
    when 'Supplier'
      Supplier.find_by(id: user_id)
    else
      nil
    end
  end
  
  # Get the item object
  def item_object
    return nil unless item_type && item_id
    
    begin
      item_type.constantize.find_by(id: item_id)
    rescue
      nil
    end
  end
  
  # Get formatted changes
  def formatted_changes
    return {} unless object_changes.present?
    
    changes = object_changes.is_a?(String) ? JSON.parse(object_changes) : object_changes
    changes.transform_values do |change|
      {
        from: change[0],
        to: change[1]
      }
    end
  end
  
  # Get the previous version
  def previous_version
    item_object&.versions&.where('created_at < ?', created_at)&.last
  end
  
  # Get the next version
  def next_version
    item_object&.versions&.where('created_at > ?', created_at)&.first
  end
  
  # Check if this is a significant change
  def significant_change?
    return false unless object_changes.present?
    
    # Define significant fields for different models
    significant_fields = case item_type
    when 'User', 'Admin', 'Supplier'
      %w[email first_name last_name role status]
    when 'Product'
      %w[name price description status]
    when 'Order'
      %w[status payment_status total_amount]
    else
      %w[name status]
    end
    
    changes = object_changes.is_a?(String) ? JSON.parse(object_changes) : object_changes
    changes.keys.any? { |key| significant_fields.include?(key) }
  end
  
  # Get a human-readable description of the change
  def change_description
    case event
    when 'create'
      "Created #{item_type.downcase}"
    when 'update'
      changes = formatted_changes
      if changes.any?
        "Updated #{item_type.downcase}: #{changes.keys.join(', ')}"
      else
        "Updated #{item_type.downcase}"
      end
    when 'destroy'
      "Deleted #{item_type.downcase}"
    else
      "#{event.capitalize} #{item_type.downcase}"
    end
  end
end


