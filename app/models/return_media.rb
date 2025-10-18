class ReturnMedia < ApplicationRecord
  belongs_to :return_item

  enum :media_type, { image: 'image', video: 'video' }
end
