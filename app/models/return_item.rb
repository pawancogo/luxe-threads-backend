class ReturnItem < ApplicationRecord
  belongs_to :return_request
  belongs_to :order_item
  has_many :return_media, class_name: 'ReturnMedia', dependent: :destroy
end
