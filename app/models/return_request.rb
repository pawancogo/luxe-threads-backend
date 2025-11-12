class ReturnRequest < ApplicationRecord
  # Include concerns
  include StatusTrackable
  
  belongs_to :user
  belongs_to :order
  belongs_to :order_item, optional: true
  belongs_to :resolved_by_admin, class_name: 'Admin', optional: true
  belongs_to :pickup_address, class_name: 'Address', optional: true
  
  has_many :return_items, dependent: :destroy
  has_many :order_items, through: :return_items
  
  enum status: { 
    requested: 0, 
    approved: 1, 
    rejected: 2, 
    shipped: 3, 
    received: 4, 
    completed: 5,
    cancelled: 6
  }
  enum resolution_type: { refund: 0, replacement: 1 }
  
  # Refund status (using string prefix to avoid enum conflict)
  enum refund_status: {
    refund_pending: 'pending',
    refund_processing: 'processing',
    refund_completed: 'completed',
    refund_failed: 'failed'
  }, _prefix: :refund
  
  validates :return_id, presence: true, uniqueness: true
  
  # Generate unique return_id
  before_validation :generate_return_id, on: :create
  
  # Update status_updated_at when status changes
  before_save :update_status_timestamp, if: :status_changed?

  # Ecommerce-specific scopes
  scope :for_customer, ->(customer) { where(user: customer) }
  scope :with_full_details, -> { includes(order: [:order_items, :user], return_items: [:order_item, :return_media]) }
  scope :pending_approval, -> { where(status: 'requested') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :completed, -> { where(status: 'completed') }
  
  # Status history is handled by StatusTrackable concern
  # status_history_data and status_history_data= are provided by the concern
  
  # Parse return_images JSON
  def return_images_list
    return [] if return_images.blank?
    JSON.parse(return_images) rescue []
  end
  
  def return_images_list=(list)
    self.return_images = list.to_json
  end
  
  private
  
  def generate_return_id
    return if return_id.present?
    self.return_id = "RET-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end
  
  def update_status_timestamp
    self.status_updated_at = Time.current
    add_status_to_history(status, "Status changed to #{status}")
  end
end

