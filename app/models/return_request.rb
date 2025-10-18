class ReturnRequest < ApplicationRecord
  belongs_to :user
  belongs_to :order
  has_many :return_items, dependent: :destroy
  has_many :order_items, through: :return_items

  enum status: { requested: 0, approved: 1, rejected: 2, shipped: 3, received: 4, completed: 5 }
  enum resolution_type: { refund: 0, replacement: 1 }
end
