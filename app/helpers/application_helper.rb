module ApplicationHelper
  # RailsAdmin logout helpers
  def logout_path
    main_app.admin_logout_path
  end
  
  def logout_method
    :delete
  end
  
  # Search Manager Helpers
  def get_value(value)
    value.present? ? value : ''
  end
  
  def format_filter(value, category_name = nil)
    return value if value.blank?
    value.sort_by { |v| v.last.to_s }.map { |v| [convert_to_human(v.first), blank_filter(v)] }
  end
  
  def convert_to_human(term)
    return 'N/A' if term.nil?
    text = term.gsub(/\(.*?\)/, '').strip
    return "N/A #{term.strip.match(/\(.*\)/)}" if text.blank?
    term.titleize
  end
  
  def blank_filter(val)
    text = val.first.gsub(/\(.*?\)/, '').strip
    text.blank? ? '_blank' : val.last
  end
  
  def include_blank_by(key)
    key = case key.to_s
          when 'is_active'
            'active'
          when 'email_verified'
            'email verified'
          when 'featured'
            'featured'
          else
            key.to_s
          end
    "Select #{key.gsub(/_name|_title/, '').titleize}"
  end
  
  def filter_label_for(key, model_class = nil)
    # Try to determine model class from controller if not provided
    model_class ||= begin
      controller_name = controller.controller_name.singularize.camelize
      controller_name.constantize rescue nil
    end
    
    # Handle special cases for associations
    if key.to_s.end_with?('_id')
      association_name = key.to_s.gsub(/_id$/, '')
      begin
        # Try to get the association model
        assoc_model = model_class&.reflect_on_association(association_name.to_sym)&.klass
        if assoc_model
          return assoc_model.model_name.human
        end
      rescue
      end
    end
    
    # Use human_attribute_name if model class is available
    if model_class && model_class.respond_to?(:human_attribute_name)
      begin
        return model_class.human_attribute_name(key.to_s)
      rescue
      end
    end
    
    # Fallback to smart titleize
    key.to_s.gsub(/_name|_title|_id/, '').titleize
  end
end
