class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :sub_categories, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy

  validates :name, presence: true, uniqueness: true
end