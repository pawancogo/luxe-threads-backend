class ReturnItem < ApplicationRecord
  belongs_to :return_request
  belongs_to :order_item
  has_many :return_media, dependent: :destroy
end
