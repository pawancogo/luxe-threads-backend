# frozen_string_literal: true

class SupportTicket < ApplicationRecord
  belongs_to :user
  belongs_to :assigned_to, class_name: 'Admin', optional: true
  belongs_to :resolved_by, class_name: 'Admin', optional: true
  belongs_to :order, optional: true
  belongs_to :product, optional: true
  
  has_many :support_ticket_messages, dependent: :destroy
  
  # Categories
  enum :category, {
    order_issue: 'order_issue',
    product_issue: 'product_issue',
    payment_issue: 'payment_issue',
    account_issue: 'account_issue',
    other: 'other'
  }
  
  # Status
  enum :status, {
    open: 'open',
    in_progress: 'in_progress',
    waiting_customer: 'waiting_customer',
    resolved: 'resolved',
    closed: 'closed'
  }, default: 'open'
  
  # Priority
  enum :priority, {
    low: 'low',
    medium: 'medium',
    high: 'high',
    urgent: 'urgent'
  }, default: 'medium'
  
  validates :ticket_id, presence: true, uniqueness: true
  validates :subject, presence: true
  validates :description, presence: true
  validates :category, presence: true
  
  # Generate ticket_id
  before_validation :generate_ticket_id, on: :create
  
  # Ecommerce-specific scopes
  scope :open_tickets, -> { where(status: ['open', 'in_progress', 'waiting_customer']) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :assigned_to_admin, ->(admin_id) { where(assigned_to_id: admin_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_customer, ->(customer_id) { where(user_id: customer_id) }
  scope :with_full_details, -> { includes(:user, :assigned_to, :support_ticket_messages) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_category, ->(category) { where(category: category) }
  scope :unresolved, -> { where.not(status: ['resolved', 'closed']) }
  scope :resolved, -> { where(status: 'resolved') }
  
  # Assign ticket (delegates to service)
  def assign_to!(admin)
    service = Support::AssignmentService.new(self, admin)
    service.call
    service.success?
  end
  
  # Resolve ticket (delegates to service)
  def resolve!(admin, resolution_text = nil)
    service = Support::ResolutionService.new(self, admin, resolution_text)
    service.call
    service.success?
  end
  
  # Close ticket (delegates to service)
  def close!
    service = Support::ClosureService.new(self)
    service.call
    service.success?
  end
  
  private
  
  def generate_ticket_id
    return if ticket_id.present?
    self.ticket_id = "TKT-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end

