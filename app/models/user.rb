class User < ApplicationRecord
  has_secure_password

  # Define roles using an enum
  enum :role, {
    customer: 'customer',
    supplier: 'supplier',
    super_admin: 'super_admin',
    product_admin: 'product_admin',
    order_admin: 'order_admin'
  }

  # Associations
  has_one :supplier_profile, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_one :wishlist, dependent: :destroy
  has_many :verified_products, class_name: 'Product', foreign_key: 'verified_by_admin_id'
  after_create :create_cart
  after_create :create_wishlist

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true, uniqueness: true
  validates :role, presence: true

  # Helper method to check if user is any type of admin
  def admin?
    super_admin? || product_admin? || order_admin?
  end

  private

  def create_cart
    Cart.create(user: self)
  end

  def create_wishlist
    Wishlist.create(user: self)
  end
end