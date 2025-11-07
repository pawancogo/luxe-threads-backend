class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :order_item, optional: true # For verified purchase
  belongs_to :moderated_by, class_name: 'Admin', optional: true
  
  has_many :review_helpful_votes, dependent: :destroy
  
  # Moderation status
  enum moderation_status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected',
    flagged: 'flagged'
  }
  
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "has already reviewed this product" }
  
  scope :approved, -> { where(moderation_status: 'approved') }
  scope :featured, -> { where(is_featured: true) }
  scope :verified, -> { where(is_verified_purchase: true) }
  
  # Mark as verified if order_item exists
  before_save :mark_verified_if_ordered
  before_save :sanitize_comment
  
  # Sanitize user input to prevent XSS
  def sanitize_comment
    self.comment = ActionController::Base.helpers.sanitize(comment, tags: [], attributes: [])
  end
  
  # Parse review_images JSON
  def review_images_list
    return [] if review_images.blank?
    JSON.parse(review_images) rescue []
  end
  
  def review_images_list=(list)
    self.review_images = list.to_json
  end
  
  # Update helpful counts
  def update_helpful_counts
    self.helpful_count = review_helpful_votes.where(is_helpful: true).count
    self.not_helpful_count = review_helpful_votes.where(is_helpful: false).count
    save
  end
  
  private
  
  def mark_verified_if_ordered
    self.is_verified_purchase = true if order_item.present?
  end
end

