# frozen_string_literal: true

module SearchManager
  extend ActiveSupport::Concern

  def search_manager **options
    raise ArgumentError, "'on' options required for text based searching." if options[:on].blank?

    class_eval do
      cattr_reader :on, :aggs_on, :range_on

      class_variable_set :@@on, options[:on]
      class_variable_set :@@aggs_on, options[:aggs_on] || []
      class_variable_set :@@range_on, options[:range_on] || nil
    end
  end

  def filter_with_aggs
    @filter_with_aggs
  end

  def aggs_count aggs_as_searchkick = false, options = {}
    aggregate_count = count(options[:count_select])
    return {} if aggregate_count.blank?
    if falsy_values.any? { |key| aggregate_count.key?(key) }
      aggregate_count[nil] = aggregate_count.fetch(nil, 0) + falsy_values.sum { |key| key.nil? ? 0 : aggregate_count.delete(key) || 0 }
    end

    if aggs_as_searchkick
      {
        buckets: aggregate_count.sort_by { |_k, v| -1 * v }.map { |k, v| { key: k, count: v }.as_json },
        total_count: aggregate_count.sum { |_k, v| v }
      }.as_json
    else
      aggregate_count.map { |k, v| ["#{k} (#{v})", k] }
    end
  end

  def convert_ids_to_names(aggs_values, column_name, model_class)
    return aggs_values unless column_name.to_s.end_with?('_id')
    
    association_name = column_name.to_s.gsub(/_id$/, '')
    begin
      association = model_class.reflect_on_association(association_name.to_sym)
      return aggs_values unless association
      
      associated_class = association.klass
      id_to_name_map = {}
      
      # Get all IDs from aggregation
      ids = aggs_values.map { |v| v.last }.compact.reject { |id| id == '_blank' || id.blank? }
      
      if ids.present?
        # Fetch associated records and build a map
        associated_records = associated_class.where(id: ids)
        associated_records.each do |record|
          # Try to get name, title, company_name, or to_s
          name = record.try(:name) || record.try(:title) || record.try(:company_name) || record.try(:to_s) || record.id.to_s
          id_to_name_map[record.id.to_s] = name
        end
      end
      
      # Replace IDs with names in aggregation values
      aggs_values.map do |value_pair|
        display_value, id_value = value_pair
        # Extract count from display value (format: "value (count)")
        count_match = display_value.match(/\((\d+)\)/)
        count = count_match ? count_match[1] : '0'
        
        if id_to_name_map[id_value.to_s]
          ["#{id_to_name_map[id_value.to_s]} (#{count})", id_value]
        else
          value_pair
        end
      end
    rescue => e
      Rails.logger.error "Error converting IDs to names for #{column_name}: #{e.message}"
      aggs_values
    end
  end

  def convert_enum_values(aggs_values, column_name, model_class)
    return aggs_values unless model_class.respond_to?(:defined_enums)
    
    enum_def = model_class.defined_enums[column_name.to_sym]
    return aggs_values unless enum_def
    
    # enum_def is a hash like {"pending"=>0, "active"=>1}
    value_to_key = enum_def.invert
    
    aggs_values.map do |value_pair|
      display_value, enum_value = value_pair
      # Extract count from display value (format: "value (count)")
      count_match = display_value.match(/\((\d+)\)/)
      count = count_match ? count_match[1] : '0'
      
      # Convert enum integer value to key
      if value_to_key[enum_value.to_i]
        human_key = value_to_key[enum_value.to_i].humanize
        ["#{human_key} (#{count})", enum_value]
      else
        value_pair
      end
    end
  rescue => e
    Rails.logger.error "Error converting enum values for #{column_name}: #{e.message}"
    aggs_values
  end

  def filter_name term
    term.instance_of?(Array) ? term.first : term
  end

  def column_name term
    term.instance_of?(Array) ? term.last : term
  end

  def apply_filter query, term, params
    filter = filter_name(term)
    # Check for both string and symbol keys (Rails params can be either)
    filter_key = params.key?(filter.to_s) ? filter.to_s : (params.key?(filter.to_sym) ? filter.to_sym : nil)
    return query unless filter_key

    value = params[filter_key]
    column = column_name(term)

    # Handle blank values
    if value == '_blank' || (value.is_a?(Array) && value.all? { |v| v.blank? || v == '_blank' })
      return query.where("#{column} IS NULL OR #{column} = ?", '')
    end
    
    # Skip if value is blank (but not explicitly '_blank')
    return query if value.blank?

    # Normalize to array and convert to strings/integers as needed
    values = value.is_a?(Array) ? value.reject(&:blank?) : [value].reject(&:blank?)
    return query if values.empty?

    # Convert to appropriate type (integer for IDs, string for others)
    # Try to convert to integer if column ends with _id
    if column.to_s.end_with?('_id')
      values = values.map { |v| v.to_i }.reject { |v| v == 0 }
    else
      values = values.map(&:to_s).reject(&:blank?)
    end

    return query if values.empty?

    query.where(column => values)
  end

  def _search(params, **options)
    records = all
    fields  = (options[:on] || on).dup
    aggs_on = (options[:aggs_on] || self.aggs_on || []).dup
    aggs_as_searchkick = (options[:aggs_as_searchkick] || false).dup
    search_key = (options[:search_key] || :search).dup

    # apply text search if fields set
    # Check for both string and symbol keys (Rails params can be either)
    # Also handle ActionController::Parameters
    text = nil
    if params.respond_to?(:[])
      text = params[search_key.to_s] || params[search_key.to_sym] || params[search_key]
    elsif params.is_a?(Hash)
      text = params[search_key.to_s] || params[search_key.to_sym] || params[search_key]
    end
    
    text = text.to_s.strip if text.present?
    
    if fields.present? && text.present? && !text.blank?
      adapter = connection.adapter_name.downcase
      operator = adapter.include?('postgresql') ? 'ILIKE' : 'LIKE'
      pattern = "%#{text}%"

      conditions = fields.map { |field| "#{table_name}.#{field} #{operator} ?" }
      bindings = Array.new(fields.length, pattern)

      records = records.where([conditions.join(' OR '), *bindings])
    end

    # apply date range if required
    if (params[:date_range].present? && options[:date_range_column].present?)
      begin
        start_date, end_date = params[:date_range].split(' - ').map(&:strip)
        # Enhanced date parsing - try multiple formats like vendor-backend but with better error handling
        start_datetime = parse_date(start_date)
        end_datetime = parse_date(end_date)
        
        if start_datetime && end_datetime
          records = records.where(options[:date_range_column].dup => start_datetime.beginning_of_day..end_datetime.end_of_day)
        end
      rescue => e
        Rails.logger.error "Date range parsing error: #{e.message}"
      end
    end

    if (params[:date_range_overlap].present? && options[:date_range_overlap_column].present?)
      begin
        start_date, end_date = params[:date_range_overlap].split(' - ').map(&:strip)
        start_datetime = parse_date(start_date)
        end_datetime = parse_date(end_date)
        
        if start_datetime && end_datetime && options[:date_range_overlap_column].is_a?(Array) && options[:date_range_overlap_column].length == 2
          records = records.where(
            "#{options[:date_range_overlap_column][0]} <= ? AND #{options[:date_range_overlap_column][1]} >= ?", 
            end_datetime.end_of_day, 
            start_datetime.beginning_of_day
          )
        end
      rescue => e
        Rails.logger.error "Date range overlap parsing error: #{e.message}"
      end
    end
    
    # we will use this for count/aggregate queries
    base_count_query = records

    # apply numeric range filter if required (min/max) - generic range filter
    range_field = (options[:range_field] || self.range_on)
    if range_field.present?
      # Apply min filter if present
      if params[:min].present? && params[:min].to_f > 0
        records = records.where("#{table_name}.#{range_field} >= ?", params[:min].to_f)
      end
      # Apply max filter if present
      if params[:max].present? && params[:max].to_f > 0
        records = records.where("#{table_name}.#{range_field} <= ?", params[:max].to_f)
      end
    end

    # apply filters based on aggregation filters
    aggs_on.each do |term|
      records = apply_filter(records, term, params)
    end

    # enable pagination based on page_number and per_page
    options[:pagination] = params[:pagination] if params.key?(:pagination)
    if (options[:pagination].nil? || options[:pagination]) && params[:allowed_pagination] != false
      page = (params[:page] || 1).dup
      per_page = (params[:per_page] || 15).dup
      records = records.page(page).per(per_page)
    end

    # collect aggregation based on filters applied
    @filter_with_aggs = {}
    @filter_with_aggs.merge!({date_range: options[:date_range_column].to_s}) if options[:date_range_column].present?
    @filter_with_aggs.merge!({date_range_overlap: options[:date_range_overlap_column].map(&:to_s)}) if options[:date_range_overlap_column].present?
    if params[:export].blank? && aggs_on.present?
      aggs_on.each do |term|
        count_query = base_count_query.except(:select).except(:order).select('*')
        filter = filter_name(term)
        column = column_name(term)
        aggs_on.reject { |ag| filter_name(ag) == filter }.each do |sub_term|
          count_query = apply_filter(count_query, sub_term, params)
        end
        aggs_count_values = count_query.group(column).aggs_count(aggs_as_searchkick, options)
        
        # Convert IDs to human-readable values for association columns
        if column.to_s.end_with?('_id')
          aggs_count_values = convert_ids_to_names(aggs_count_values, column, self)
        # Convert enum integer values to human-readable keys
        elsif self.respond_to?(:defined_enums) && self.defined_enums.key?(column.to_sym)
          aggs_count_values = convert_enum_values(aggs_count_values, column, self)
        end
        
        @filter_with_aggs[filter.to_s] = aggs_count_values if aggs_count_values.present?
      end
    end

    records
  end
end

private

def falsy_values
  [nil, '']
end

# Enhanced date parsing - supports multiple formats
def parse_date(date_string)
  return nil if date_string.blank?
  
  # Try MM/DD/YYYY format first (daterangepicker default)
  begin
    return DateTime.strptime(date_string, '%m/%d/%Y')
  rescue
  end
  
  # Try M/D/YYYY format (single digit month/day)
  begin
    return DateTime.strptime(date_string, '%m/%d/%Y')
  rescue
  end
  
  # Try ISO format (YYYY-MM-DD)
  begin
    return Date.parse(date_string)
  rescue
  end
  
  # Try common formats
  begin
    return DateTime.parse(date_string)
  rescue
  end
  
  nil
end

ActiveSupport.on_load(:active_record) do
  extend SearchManager
end

