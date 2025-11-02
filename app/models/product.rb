class Product < ApplicationRecord
  # Include shared behavior
  include Auditable

  # Associations - only associations
  belongs_to :supplier_profile
  belongs_to :category
  belongs_to :brand
  belongs_to :verified_by_admin, class_name: 'Admin', optional: true

  has_many :product_variants, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :product_attributes, dependent: :destroy
  has_many :attribute_values, through: :product_attributes

  # Enums
  enum :status, { pending: 0, active: 1, rejected: 2, archived: 3 }

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 255 }
  validates :description, presence: true, length: { minimum: 10 }

  # Presentation logic moved to ProductPresenter
  # Search logic can be moved to SearchService if needed
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