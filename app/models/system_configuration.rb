# frozen_string_literal: true

class SystemConfiguration < ApplicationRecord
  # Associations
  belongs_to :created_by, polymorphic: true, optional: true

  # Validations
  validates :key, presence: true, uniqueness: { case_sensitive: false }
  validates :value_type, inclusion: { in: %w[string integer float boolean json] }
  validates :category, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_key, ->(key) { where(key: key) }
  scope :by_creator, ->(creator) { where(created_by: creator) }
  scope :by_creator_type, ->(type) { where(created_by_type: type) }

  # Callbacks
  before_save :normalize_value

  # Class methods for easy access
  class << self
    # Get a configuration value by key
    # @param key [String] The configuration key
    # @param default [Object] Default value if key not found
    # @return [Object] The typed value
    def get(key, default = nil)
      config = active.find_by(key: key.to_s)
      return default unless config
      config.cast_value
    end

    # Set a configuration value
    # @param key [String] The configuration key
    # @param value [Object] The value to set
    # @param options [Hash] Options hash
    # @option options [String] :value_type ('string') Type of value
    # @option options [String] :category ('general') Category
    # @option options [String] :description (nil) Description
    # @option options [Boolean] :is_active (true) Active status
    # @option options [Object] :created_by (nil) Creator (Admin, User, etc.)
    # @return [SystemConfiguration] The configuration object
    def set(key, value, value_type: 'string', category: 'general', description: nil, is_active: true, created_by: nil)
      config = find_or_initialize_by(key: key.to_s)
      config.value = value.to_s
      config.value_type = value_type
      config.category = category
      config.description = description if description
      config.is_active = is_active
      config.created_by = created_by if created_by
      config.save!
      config
    end

    # Get all configurations as a hash
    # @param category [String, nil] Optional category filter
    # @return [Hash] Hash of key-value pairs
    def all_as_hash(category: nil)
      scope = active
      scope = scope.by_category(category) if category
      scope.pluck(:key, :value, :value_type).each_with_object({}) do |(key, value, value_type), hash|
        hash[key] = cast_value_by_type(value, value_type)
      end
    end

    # Bulk set configurations
    # @param configs [Hash] Hash of key-value pairs
    # @param options [Hash] Default options for all configs
    # @return [Array<SystemConfiguration>] Array of configuration objects
    def bulk_set(configs, **options)
      configs.map do |key, value|
        if value.is_a?(Hash)
          set(key, value[:value], **options.merge(value.except(:value)))
        else
          set(key, value, **options)
        end
      end
    end

    # Get configurations created by a specific user/admin
    # @param creator [Object] The creator object (Admin, User, etc.)
    # @return [ActiveRecord::Relation] Collection of configurations
    def by_creator(creator)
      where(created_by: creator)
    end

    # Get configurations by creator type and role (for role-based filtering)
    # @param creator_type [String] Type of creator ('Admin', 'User', etc.)
    # @param role [String, nil] Optional role filter (for Admin)
    # @return [ActiveRecord::Relation] Collection of configurations
    def by_creator_type_and_role(creator_type, role: nil)
      scope = by_creator_type(creator_type)
      if creator_type == 'Admin' && role.present?
        # Use safe parameterized query to prevent SQL injection
        admin_ids = Admin.where(role: role).pluck(:id)
        scope = scope.where(created_by_id: admin_ids)
      end
      scope
    end

    # Get configurations by admin role
    # @param role [String] Admin role
    # @return [ActiveRecord::Relation] Collection of configurations
    def by_admin_role(role)
      admin_ids = Admin.where(role: role).pluck(:id)
      where(created_by_type: 'Admin', created_by_id: admin_ids)
    end

    private

    def cast_value_by_type(value, value_type)
      case value_type
      when 'integer'
        value.to_i
      when 'float'
        value.to_f
      when 'boolean'
        value.to_s.downcase.in?(%w[true 1 yes])
      when 'json'
        JSON.parse(value) rescue value
      else
        value
      end
    end
  end

  # Instance method to cast value to appropriate type
  def cast_value
    self.class.send(:cast_value_by_type, value, value_type)
  end

  # Check if configuration is active
  def active?
    is_active?
  end

  # Deactivate configuration
  def deactivate!
    update!(is_active: false)
  end

  # Activate configuration
  def activate!
    update!(is_active: true)
  end

  # Get creator name
  def creator_name
    return 'System' unless created_by
    if created_by.respond_to?(:full_name)
      created_by.full_name
    elsif created_by.respond_to?(:first_name) && created_by.respond_to?(:last_name)
      "#{created_by.first_name} #{created_by.last_name}".strip
    elsif created_by.respond_to?(:name)
      created_by.name
    elsif created_by.respond_to?(:email)
      created_by.email
    else
      "#{created_by_type} ##{created_by_id}"
    end
  end

  # Check if created by admin
  def created_by_admin?
    created_by_type == 'Admin'
  end

  # Check if created by user
  def created_by_user?
    created_by_type == 'User'
  end

  private

  # Normalize value based on value_type before saving
  def normalize_value
    self.value = case value_type
    when 'integer'
      value.to_i.to_s
    when 'float'
      value.to_f.to_s
    when 'boolean'
      value.to_s.downcase.in?(%w[true 1 yes]) ? 'true' : 'false'
    when 'json'
      value.is_a?(String) ? value : value.to_json
    else
      value.to_s
    end
  end
end

