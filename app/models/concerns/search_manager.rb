# frozen_string_literal: true

module SearchManager
  extend ActiveSupport::Concern

  def search_manager **options
    raise ArgumentError, "'on' options required for text based searching." if options[:on].blank?

    class_eval do
      cattr_reader :on, :aggs_on

      class_variable_set :@@on, options[:on]
      class_variable_set :@@aggs_on, options[:aggs_on] || []
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

  def filter_name term
    term.instance_of?(Array) ? term.first : term
  end

  def column_name term
    term.instance_of?(Array) ? term.last : term
  end

  def apply_filter query, term, params
    filter = filter_name(term)
    if params[filter].present? && value ||= params[filter]
      query = if value == '_blank' || (value.is_a?(Array) && value.all?(&:blank?))
                #value can be '' or nil
                query.where("#{column_name(term)} IS NULL OR #{column_name(term)} =? ",'')
              else
                query.where("#{column_name(term)} IN (?)", value)
              end
    end
    query
  end

  def _search(params, **options)
    records = all
    fields  = (options[:on] || on).dup
    aggs_on = (options[:aggs_on] || self.aggs_on || []).dup
    aggs_as_searchkick = (options[:aggs_as_searchkick] || false).dup
    search_key = (options[:search_key] || :search).dup

    # apply text search if fields set
    text_search = []
    text = params[search_key]
    if fields.present? && text.present?
      # Postgresql searches apostrophe with double apostrophe symbol
      text = text.gsub("'", "''")

      fields.each do |field|
        text_search << "#{table_name}.#{field} ILIKE '%#{text}%'"
      end

      records = records.where(text_search.join(' OR '))
    end

    # apply date range if required
    if (params[:date_range].present? && options[:date_range_column].present?)
      begin
        start_date, end_date = params[:date_range].split(' - ').map(&:strip)
        # Try multiple date formats
        start_datetime = begin
          DateTime.strptime(start_date, '%m/%d/%Y')
        rescue
          begin
            Date.parse(start_date)
          rescue
            nil
          end
        end
        
        end_datetime = begin
          DateTime.strptime(end_date, '%m/%d/%Y')
        rescue
          begin
            Date.parse(end_date)
          rescue
            nil
          end
        end
        
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
        # Try multiple date formats
        start_datetime = begin
          DateTime.strptime(start_date, '%m/%d/%Y')
        rescue
          begin
            Date.parse(start_date)
          rescue
            nil
          end
        end
        
        end_datetime = begin
          DateTime.strptime(end_date, '%m/%d/%Y')
        rescue
          begin
            Date.parse(end_date)
          rescue
            nil
          end
        end
        
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

    # apply numeric range filter if required (min/max)
    if params[:range_term].present? && params[:min].present? && params[:max].present?
      range_field = params[:range_term]
      min_value = params[:min].to_f
      max_value = params[:max].to_f
      if min_value > 0 || max_value > 0
        records = records.where("#{table_name}.#{range_field} >= ? AND #{table_name}.#{range_field} <= ?", min_value, max_value)
      end
    elsif params[:range_term].present?
      range_field = params[:range_term]
      if params[:min].present? && params[:min].to_f > 0
        records = records.where("#{table_name}.#{range_field} >= ?", params[:min].to_f)
      end
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
        aggs_on.reject { |ag| filter_name(ag) == filter }.each do |sub_term|
          count_query = apply_filter(count_query, sub_term, params)
        end
        aggs_count_values = count_query.group(column_name(term)).aggs_count(aggs_as_searchkick, options)
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

ActiveSupport.on_load(:active_record) do
  extend SearchManager
end

