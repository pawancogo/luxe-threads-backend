class Product < ApplicationRecord
  # searchkick # Temporarily disabled for seeding

  belongs_to :supplier_profile
  belongs_to :category
  belongs_to :brand
  belongs_to :verified_by_admin, class_name: 'User', optional: true

  has_many :product_variants, dependent: :destroy
  has_many :reviews, dependent: :destroy

  enum :status, { pending: 0, active: 1, rejected: 2, archived: 3 }

  validates :name, presence: true
  validates :description, presence: true

  def search_data
    {
      id: id,
      name: name,
      description: description,
      status: status,
      brand_name: brand.name,
      category_name: category.name,
      supplier_name: supplier_profile.company_name,
      variants: product_variants.map do |variant|
        {
          price: variant.price,
          discounted_price: variant.discounted_price,
        }
      end
    }
  end
end