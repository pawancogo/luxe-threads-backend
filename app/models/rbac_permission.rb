# frozen_string_literal: true

# RBAC Permission Model
# Defines individual permissions that can be assigned to roles
class RbacPermission < ApplicationRecord
  # Associations
  has_many :rbac_role_permissions, dependent: :destroy
  has_many :rbac_roles, through: :rbac_role_permissions
  
  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_:-]+\z/ }
  validates :resource_type, presence: true
  validates :action, presence: true
  validates :category, presence: true
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :by_resource, ->(resource) { where(resource_type: resource) }
  scope :by_action, ->(action) { where(action: action) }
  
  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  before_validation :normalize_slug
  
  # Instance methods
  def can_delete?
    !is_system && rbac_roles.none?
  end
  
  def full_permission
    "#{resource_type}:#{action}"
  end
  
  private
  
  def generate_slug
    self.slug = "#{resource_type}:#{action}".downcase.parameterize
  end
  
  def normalize_slug
    self.slug = slug.downcase.strip.gsub(/\s+/, '_') if slug.present?
  end
end

