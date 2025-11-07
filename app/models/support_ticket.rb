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
  
  scope :open_tickets, -> { where(status: ['open', 'in_progress', 'waiting_customer']) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :assigned_to, ->(admin_id) { where(assigned_to_id: admin_id) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Assign ticket
  def assign_to!(admin)
    update(assigned_to: admin, assigned_at: Time.current, status: 'in_progress')
  end
  
  # Resolve ticket
  def resolve!(admin, resolution_text = nil)
    update(
      resolved_by: admin,
      resolved_at: Time.current,
      resolution: resolution_text,
      status: 'resolved'
    )
  end
  
  # Close ticket
  def close!
    update(status: 'closed', closed_at: Time.current)
  end
  
  private
  
  def generate_ticket_id
    return if ticket_id.present?
    self.ticket_id = "TKT-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
end

