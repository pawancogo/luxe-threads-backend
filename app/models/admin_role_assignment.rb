# frozen_string_literal: true

# Admin Role Assignment Model
# Links admins to RBAC roles with custom permissions
class AdminRoleAssignment < ApplicationRecord
  # Associations
  belongs_to :admin
  belongs_to :rbac_role
  belongs_to :assigned_by, class_name: 'Admin', optional: true
  
  # Validations
  validates :admin_id, uniqueness: { scope: :rbac_role_id, message: "already has this role assigned" }
  validates :assigned_at, presence: true
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :current, -> { active.where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at IS NOT NULL AND expires_at <= ?', Time.current) }
  
  # Callbacks
  before_validation :set_assigned_at, if: -> { assigned_at.blank? }
  
  # Instance methods
  def expired?
    expires_at.present? && expires_at <= Time.current
  end
  
  def active?
    is_active && !expired?
  end
  
  def custom_permissions_hash
    return {} if custom_permissions.blank?
    custom_permissions.is_a?(Hash) ? custom_permissions : JSON.parse(custom_permissions) rescue {}
  end
  
  def has_custom_permission?(permission_slug)
    perms = custom_permissions_hash
    perms[permission_slug.to_s] == true
  end
  
  private
  
  def set_assigned_at
    self.assigned_at = Time.current
  end
end

