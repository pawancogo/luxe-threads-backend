# frozen_string_literal: true

# RBAC Role Model
# Defines roles that can be assigned to admins or suppliers
class RbacRole < ApplicationRecord
  # Associations
  has_many :rbac_role_permissions, dependent: :destroy
  has_many :rbac_permissions, through: :rbac_role_permissions
  has_many :admin_role_assignments, dependent: :destroy
  has_many :admins, through: :admin_role_assignments
  has_many :supplier_account_users, dependent: :nullify
  
  # Validations
  validates :name, presence: true, uniqueness: { scope: :role_type }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_-]+\z/ }
  validates :role_type, presence: true, inclusion: { in: %w[admin supplier system] }
  validates :priority, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :system_roles, -> { where(is_system: true) }
  scope :by_type, ->(type) { where(role_type: type) }
  scope :for_admin, -> { where(role_type: ['admin', 'system']) }
  scope :for_supplier, -> { where(role_type: ['supplier', 'system']) }
  
  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? && name.present? }
  before_validation :normalize_slug
  
  # Instance methods
  def can_delete?
    !is_system && admin_role_assignments.none? && supplier_account_users.none?
  end
  
  def has_permission?(permission_slug)
    rbac_permissions.active.exists?(slug: permission_slug)
  end
  
  def permission_slugs
    rbac_permissions.active.pluck(:slug)
  end
  
  private
  
  def generate_slug
    self.slug = name.downcase.parameterize
  end
  
  def normalize_slug
    self.slug = slug.downcase.strip.gsub(/\s+/, '_') if slug.present?
  end
end

