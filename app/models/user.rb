class User < ApplicationRecord
  has_secure_password

  # Define roles using an enum
  enum role: {
    customer: 0,
    supplier: 1,
    super_admin: 2,
    product_admin: 3,
    order_admin: 4
  }

  # Associations
  has_one :supplier_profile, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :cart, dependent: :destroy
  after_create :create_cart

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true, uniqueness: true
  validates :role, presence: true

  private

  def create_cart
    Cart.create(user: self)
  end
end