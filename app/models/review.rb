class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true
  validates :user_id, uniqueness: { scope: :product_id, message: "has already reviewed this product" }
end
