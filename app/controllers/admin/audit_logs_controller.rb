class Admin::AuditLogsController < Admin::BaseController
  before_action :require_super_admin!
  before_action :enable_date_filter, only: [:index]

  def index
    search_params = params.except(:controller, :action).permit(:search, :per_page, :page, :item_type, :event, :whodunnit, :date_range, :min, :max)
    search_options = { date_range_column: :created_at }
    search_options[:range_field] = @filters[:range_field] if @filters[:range_field].present?
    
    @versions = Version._search(search_params, **search_options).order(created_at: :desc)
    
    # Merge filters (this will include aggregations)
    begin
      filter_aggs = @versions.filter_with_aggs if @versions.respond_to?(:filter_with_aggs)
      @filters.merge!(filter_aggs) if filter_aggs.present?
    rescue => e
      Rails.logger.error "Error merging filters: #{e.message}"
      @filters ||= { search: [nil] }
    end
  end

  def show
    @version = Version.find(params[:id])
    @item = @version.item_object
    @user = @version.user_object
  end
end


