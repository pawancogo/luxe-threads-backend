# Proposed Implementation: All Models (Complete)

This document contains the complete and detailed code for every model required by the application, reflecting our final database schema.

---

### `app/models/user.rb`
```ruby
class User < ApplicationRecord
  has_secure_password
  enum role: { customer: 'customer', supplier: 'supplier', super_admin: 'super_admin', product_admin: 'product_admin', order_admin: 'order_admin' }
  
  has_one :supplier_profile, dependent: :destroy
  has_one :wishlist, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :return_requests, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
end
```

---

### `app/models/supplier_profile.rb`
```ruby
class SupplierProfile < ApplicationRecord
  belongs_to :user
  has_many :products, dependent: :destroy
  validates :user_id, uniqueness: true
  validates :company_name, presence: true
end
```

---

### `app/models/product.rb`
```ruby
class Product < ApplicationRecord
  belongs_to :supplier_profile
  belongs_to :category
  belongs_to :brand
  belongs_to :verified_by, class_name: 'User', foreign_key: 'verified_by_admin_id', optional: true

  has_many :product_variants, dependent: :destroy
  has_many :reviews, dependent: :destroy
  
  enum status: { pending: 'pending', active: 'active', rejected: 'rejected', archived: 'archived' }
  validates :name, :description, :status, presence: true
end
```

---

### `app/models/product_variant.rb`
```ruby
class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :product_images, dependent: :destroy
  has_many :product_variant_attributes, dependent: :destroy
  has_many :attribute_values, through: :product_variant_attributes
  has_many :wishlist_items, dependent: :destroy
  has_many :order_items

  validates :sku, presence: true, uniqueness: true
  validates :price, :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
```

---

### `app/models/category.rb`
```ruby
class Category < ApplicationRecord
  has_many :products
  belongs_to :parent_category, class_name: 'Category', optional: true
  has_many :sub_categories, class_name: 'Category', foreign_key: 'parent_category_id'
  validates :name, presence: true, uniqueness: { scope: :parent_category_id }
end
```

---

### `app/models/brand.rb`
```ruby
class Brand < ApplicationRecord
  has_many :products
  validates :name, presence: true, uniqueness: true
end
```

---

### `app/models/address.rb`
```ruby
class Address < ApplicationRecord
  belongs_to :user
  validates :full_name, :phone_number, :line1, :city, :state, :postal_code, :country, :address_type, presence: true
end
```

---

### `app/models/order.rb`
```ruby
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :shipping_address, class_name: 'Address'
  belongs_to :billing_address, class_name: 'Address'
  has_many :order_items, dependent: :destroy
  has_many :return_requests, dependent: :destroy

  enum status: { pending: 'pending', paid: 'paid', packed: 'packed', shipped: 'shipped', delivered: 'delivered', cancelled: 'cancelled' }
  enum payment_status: { pending: 'pending', complete: 'complete', failed: 'failed' }
  validates :total_amount, presence: true
end
```

---

### `app/models/order_item.rb`
```ruby
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant
  has_many :return_items

  validates :quantity, :price_at_purchase, presence: true
end
```

---

### `app/models/wishlist.rb`
```ruby
class Wishlist < ApplicationRecord
  belongs_to :user
  has_many :wishlist_items, dependent: :destroy
  validates :user_id, uniqueness: true
end
```

---

### `app/models/wishlist_item.rb`
```ruby
class WishlistItem < ApplicationRecord
  belongs_to :wishlist
  belongs_to :product_variant
  validates :product_variant_id, uniqueness: { scope: :wishlist_id, message: "is already in wishlist" }
end
```

---

### `app/models/review.rb`
```ruby
class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :product_id, message: "has already reviewed this product" }
end
```

---

### `app/models/return_request.rb`
```ruby
class ReturnRequest < ApplicationRecord
  belongs_to :user
  belongs_to :order
  has_many :return_items, dependent: :destroy

  enum status: { requested: 'requested', approved: 'approved', rejected: 'rejected', shipped: 'shipped', received: 'received', completed: 'completed' }
  enum resolution_type: { refund: 'refund', replacement: 'replacement' }
end
```

---

### `app/models/return_item.rb`
```ruby
class ReturnItem < ApplicationRecord
  belongs_to :return_request
  belongs_to :order_item
  has_many :return_media, dependent: :destroy
end
```
*(Plus other minor models like `ProductImage`, `AttributeType`, `AttributeValue`, `ReturnMedia` etc. would be included)*