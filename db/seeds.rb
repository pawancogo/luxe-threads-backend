# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting to seed the database..."

# Create Categories
puts "Creating categories..."
categories = [
  { name: "Men's Clothing" },
  { name: "Women's Clothing" },
  { name: "Accessories" },
  { name: "Shoes" },
  { name: "Bags" },
  { name: "Jewelry" }
]

categories.each do |category_attrs|
  Category.find_or_create_by!(name: category_attrs[:name])
end

# Create Brands
puts "Creating brands..."
brands = [
  { name: "Nike", logo_url: "https://example.com/nike-logo.png" },
  { name: "Adidas", logo_url: "https://example.com/adidas-logo.png" },
  { name: "Zara", logo_url: "https://example.com/zara-logo.png" },
  { name: "H&M", logo_url: "https://example.com/hm-logo.png" },
  { name: "Gucci", logo_url: "https://example.com/gucci-logo.png" },
  { name: "Prada", logo_url: "https://example.com/prada-logo.png" }
]

brands.each do |brand_attrs|
  Brand.find_or_create_by!(name: brand_attrs[:name]) do |brand|
    brand.logo_url = brand_attrs[:logo_url]
  end
end

# Create Admins
puts "Creating admins..."
admins = [
  {
    first_name: "Super",
    last_name: "Admin",
    email: "admin@luxethreads.com",
    phone_number: "+1234567892",
    password: "Admin@123",
    role: "super_admin"
  },
  {
    first_name: "Product",
    last_name: "Manager",
    email: "product.admin@luxethreads.com",
    phone_number: "+1234567895",
    password: "Product@123",
    role: "product_admin"
  },
  {
    first_name: "Order",
    last_name: "Manager",
    email: "order.admin@luxethreads.com",
    phone_number: "+1234567896",
    password: "Order@123",
    role: "order_admin"
  },
  {
    first_name: "User",
    last_name: "Manager",
    email: "user.admin@luxethreads.com",
    phone_number: "+1234567897",
    password: "User@123",
    role: "user_admin"
  },
  {
    first_name: "Supplier",
    last_name: "Manager",
    email: "supplier.admin@luxethreads.com",
    phone_number: "+1234567898",
    password: "Supplier@123",
    role: "supplier_admin"
  }
]

admins.each do |admin_attrs|
  Admin.find_or_create_by!(email: admin_attrs[:email]) do |admin|
    admin.first_name = admin_attrs[:first_name]
    admin.last_name = admin_attrs[:last_name]
    admin.phone_number = admin_attrs[:phone_number]
    admin.password = admin_attrs[:password]
    admin.role = admin_attrs[:role]
    admin.email_verified = true
  end
end

# Create Users (Customers)
puts "Creating users..."
users = [
  {
    first_name: "John",
    last_name: "Doe",
    email: "john.doe@example.com",
    phone_number: "+1234567890",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Jane",
    last_name: "Smith",
    email: "jane.smith@example.com",
    phone_number: "+1234567891",
    password: "password123",
    role: "premium_customer"
  },
  {
    first_name: "VIP",
    last_name: "Customer",
    email: "vip.customer@example.com",
    phone_number: "+1234567899",
    password: "password123",
    role: "vip_customer"
  }
]

users.each do |user_attrs|
  User.find_or_create_by!(email: user_attrs[:email]) do |user|
    user.first_name = user_attrs[:first_name]
    user.last_name = user_attrs[:last_name]
    user.phone_number = user_attrs[:phone_number]
    user.password = user_attrs[:password]
    user.role = user_attrs[:role]
    user.email_verified = true
  end
end

# Create Suppliers
puts "Creating suppliers..."
suppliers = [
  {
    first_name: "Supplier",
    last_name: "One",
    email: "supplier1@example.com",
    phone_number: "+1234567893",
    password: "password123",
    role: "verified_supplier"
  },
  {
    first_name: "Supplier",
    last_name: "Two",
    email: "supplier2@example.com",
    phone_number: "+1234567894",
    password: "password123",
    role: "premium_supplier"
  },
  {
    first_name: "Partner",
    last_name: "Supplier",
    email: "partner.supplier@example.com",
    phone_number: "+1234567900",
    password: "password123",
    role: "partner_supplier"
  }
]

suppliers.each do |supplier_attrs|
  Supplier.find_or_create_by!(email: supplier_attrs[:email]) do |supplier|
    supplier.first_name = supplier_attrs[:first_name]
    supplier.last_name = supplier_attrs[:last_name]
    supplier.phone_number = supplier_attrs[:phone_number]
    supplier.password = supplier_attrs[:password]
    supplier.role = supplier_attrs[:role]
    supplier.email_verified = true
  end
end

# Create Supplier Profiles
puts "Creating supplier profiles..."
suppliers = Supplier.all
supplier_profiles = [
  {
    supplier: suppliers.first,
    company_name: "Fashion Forward Ltd",
    gst_number: "GST123456789001",
    description: "Premium fashion supplier specializing in contemporary clothing",
    website_url: "https://fashionforward.com",
    verified: true
  },
  {
    supplier: suppliers.second,
    company_name: "Style Masters Inc",
    gst_number: "GST987654321002",
    description: "Leading supplier of trendy accessories and footwear",
    website_url: "https://stylemasters.com",
    verified: false
  }
]

supplier_profiles.each do |profile_attrs|
  SupplierProfile.find_or_create_by!(supplier: profile_attrs[:supplier]) do |profile|
    profile.company_name = profile_attrs[:company_name]
    profile.gst_number = profile_attrs[:gst_number]
    profile.description = profile_attrs[:description]
    profile.website_url = profile_attrs[:website_url]
    profile.verified = profile_attrs[:verified]
  end
end

# Create Products
puts "Creating products..."
categories = Category.all
brands = Brand.all
supplier_profiles = SupplierProfile.all

products = [
  {
    name: "Classic White T-Shirt",
    description: "Premium cotton t-shirt with a comfortable fit. Perfect for everyday wear.",
    supplier_profile: supplier_profiles.first,
    category: categories.first,
    brand: brands.first,
    status: "active"
  },
  {
    name: "Denim Jeans",
    description: "High-quality denim jeans with a modern slim fit. Made from sustainable materials.",
    supplier_profile: supplier_profiles.first,
    category: categories.first,
    brand: brands.second,
    status: "active"
  },
  {
    name: "Summer Dress",
    description: "Elegant summer dress perfect for warm weather. Lightweight and breathable fabric.",
    supplier_profile: supplier_profiles.second,
    category: categories.second,
    brand: brands.third,
    status: "pending"
  },
  {
    name: "Leather Handbag",
    description: "Luxury leather handbag with multiple compartments. Handcrafted with attention to detail.",
    supplier_profile: supplier_profiles.second,
    category: categories.fifth,
    brand: brands.fifth,
    status: "active"
  },
  {
    name: "Running Shoes",
    description: "High-performance running shoes with advanced cushioning technology.",
    supplier_profile: supplier_profiles.first,
    category: categories.fourth,
    brand: brands.first,
    status: "rejected"
  }
]

products.each do |product_attrs|
  Product.find_or_create_by!(name: product_attrs[:name]) do |product|
    product.description = product_attrs[:description]
    product.supplier_profile = product_attrs[:supplier_profile]
    product.category = product_attrs[:category]
    product.brand = product_attrs[:brand]
    product.status = product_attrs[:status]
  end
end

# Create Product Variants
puts "Creating product variants..."
products = Product.all

products.each do |product|
  variants = [
    {
      sku: "#{product.name.parameterize}-small",
      price: rand(20..100),
      discounted_price: rand(15..80),
      stock_quantity: rand(10..50),
      weight_kg: rand(0.1..2.0)
    },
    {
      sku: "#{product.name.parameterize}-medium",
      price: rand(20..100),
      discounted_price: rand(15..80),
      stock_quantity: rand(10..50),
      weight_kg: rand(0.1..2.0)
    },
    {
      sku: "#{product.name.parameterize}-large",
      price: rand(20..100),
      discounted_price: rand(15..80),
      stock_quantity: rand(10..50),
      weight_kg: rand(0.1..2.0)
    }
  ]

  variants.each do |variant_attrs|
    ProductVariant.find_or_create_by!(product: product, sku: variant_attrs[:sku]) do |variant|
      variant.price = variant_attrs[:price]
      variant.discounted_price = variant_attrs[:discounted_price]
      variant.stock_quantity = variant_attrs[:stock_quantity]
      variant.weight_kg = variant_attrs[:weight_kg]
    end
  end
end

# Note: Attribute Types and Values are automatically seeded via migration
# They are defined in config/initializers/attribute_constants.rb
# and seeded in db/migrate/20251102000000_seed_predefined_attribute_types.rb
puts "ℹ️  Attribute types and values are automatically seeded during migration"
puts "   #{AttributeType.count} attribute types with #{AttributeValue.count} values available"

# Create Addresses
puts "Creating addresses..."
customers = User.where(role: "customer")

customers.each do |customer|
  addresses = [
    {
      address_type: "shipping",
      full_name: "#{customer.first_name} #{customer.last_name}",
      phone_number: customer.phone_number,
      line1: "123 Main Street",
      line2: "Apt 4B",
      city: "New York",
      state: "NY",
      postal_code: "10001",
      country: "USA"
    },
    {
      address_type: "billing",
      full_name: "#{customer.first_name} #{customer.last_name}",
      phone_number: customer.phone_number,
      line1: "456 Oak Avenue",
      line2: "",
      city: "New York",
      state: "NY",
      postal_code: "10002",
      country: "USA"
    }
  ]

  addresses.each do |address_attrs|
    Address.find_or_create_by!(user: customer, address_type: address_attrs[:address_type]) do |address|
      address.full_name = address_attrs[:full_name]
      address.phone_number = address_attrs[:phone_number]
      address.line1 = address_attrs[:line1]
      address.line2 = address_attrs[:line2]
      address.city = address_attrs[:city]
      address.state = address_attrs[:state]
      address.postal_code = address_attrs[:postal_code]
      address.country = address_attrs[:country]
    end
  end
end

# Create Orders
puts "Creating orders..."
customers = User.where(role: "customer")
product_variants = ProductVariant.all

customers.each do |customer|
  shipping_address = customer.addresses.find_by(address_type: "shipping")
  billing_address = customer.addresses.find_by(address_type: "billing")
  
  orders = [
    {
      shipping_address: shipping_address,
      billing_address: billing_address,
      status: "delivered",
      payment_status: "payment_complete",
      shipping_method: "standard",
      total_amount: rand(50..200)
    },
    {
      shipping_address: shipping_address,
      billing_address: billing_address,
      status: "shipped",
      payment_status: "payment_complete",
      shipping_method: "express",
      total_amount: rand(50..200)
    }
  ]

  orders.each do |order_attrs|
    order = Order.find_or_create_by!(user: customer, total_amount: order_attrs[:total_amount]) do |o|
      o.shipping_address = order_attrs[:shipping_address]
      o.billing_address = order_attrs[:billing_address]
      o.status = order_attrs[:status]
      o.payment_status = order_attrs[:payment_status]
      o.shipping_method = order_attrs[:shipping_method]
    end

    # Create order items
    selected_variants = product_variants.sample(rand(1..3))
    selected_variants.each do |variant|
      OrderItem.find_or_create_by!(order: order, product_variant: variant) do |item|
        item.quantity = rand(1..3)
        item.price_at_purchase = variant.price
      end
    end
  end
end

puts "✅ Database seeding completed successfully!"
puts "📊 Summary:"
puts "   - #{Category.count} categories created"
puts "   - #{Brand.count} brands created"
puts "   - #{Admin.count} admins created"
puts "   - #{User.count} users created"
puts "   - #{Supplier.count} suppliers created"
puts "   - #{SupplierProfile.count} supplier profiles created"
puts "   - #{Product.count} products created"
puts "   - #{ProductVariant.count} product variants created"
puts "   - #{AttributeType.count} attribute types created"
puts "   - #{AttributeValue.count} attribute values created"
puts "   - #{Address.count} addresses created"
puts "   - #{Order.count} orders created"
puts "   - #{OrderItem.count} order items created"
puts ""
puts "🔑 Admin Logins:"
puts "   Super Admin:"
puts "     Email: admin@luxethreads.com"
puts "     Password: Admin@123"
puts "   Product Admin:"
puts "     Email: product.admin@luxethreads.com"
puts "     Password: Product@123"
puts "   Order Admin:"
puts "     Email: order.admin@luxethreads.com"
puts "     Password: Order@123"
puts "   User Admin:"
puts "     Email: user.admin@luxethreads.com"
puts "     Password: User@123"
puts "   Supplier Admin:"
puts "     Email: supplier.admin@luxethreads.com"
puts "     Password: Supplier@123"
puts ""
puts "🌐 Access RailsAdmin at: http://localhost:3000/admin"
