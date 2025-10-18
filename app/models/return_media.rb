class ReturnMedia < ApplicationRecord
  belongs_to :return_item

  enum media_type: { image: 0, video: 1 }
end
