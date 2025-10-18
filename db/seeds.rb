# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create admin user
admin = User.find_or_create_by(email: 'admin@luxethreads.com') do |user|
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.phone_number = '0000000000'
  user.password = 'admin123'
  user.password_confirmation = 'admin123'
  user.role = 'super_admin'
end

puts "✅ Created admin user: #{admin.email}"

# Create sample categories
categories = [
  { name: 'Clothing' },
  { name: 'Accessories' },
  { name: 'Shoes' },
  { name: 'Bags' }
]

categories.each do |cat_data|
  Category.find_or_create_by(name: cat_data[:name])
end

puts "✅ Created categories"

# Create sample brands
brands = [
  { name: 'Nike', logo_url: 'https://example.com/nike-logo.png' },
  { name: 'Adidas', logo_url: 'https://example.com/adidas-logo.png' },
  { name: 'Zara', logo_url: 'https://example.com/zara-logo.png' },
  { name: 'H&M', logo_url: 'https://example.com/hm-logo.png' }
]

brands.each do |brand_data|
  Brand.find_or_create_by(name: brand_data[:name]) do |brand|
    brand.logo_url = brand_data[:logo_url]
  end
end

puts "✅ Created brands"

# Create sample supplier
supplier = User.find_or_create_by(email: 'supplier@example.com') do |user|
  user.first_name = 'Jane'
  user.last_name = 'Supplier'
  user.phone_number = '1111111111'
  user.password = 'supplier123'
  user.password_confirmation = 'supplier123'
  user.role = 'supplier'
end

# Create supplier profile
if supplier.supplier_profile.blank?
  supplier.create_supplier_profile!(
    company_name: 'Fashion Supplies Inc.',
    gst_number: 'GST123456789',
    description: 'Premium fashion supplier',
    website_url: 'https://fashionsupplies.com',
    verified: true
  )
end

puts "✅ Created supplier: #{supplier.email}"

# Create sample customer
customer = User.find_or_create_by(email: 'customer@example.com') do |user|
  user.first_name = 'John'
  user.last_name = 'Customer'
  user.phone_number = '2222222222'
  user.password = 'customer123'
  user.password_confirmation = 'customer123'
  user.role = 'customer'
end

puts "✅ Created customer: #{customer.email}"

# Create sample products
if supplier.supplier_profile.products.count == 0
  clothing_category = Category.find_by(name: 'Clothing')
  nike_brand = Brand.find_by(name: 'Nike')
  
  product = supplier.supplier_profile.products.create!(
    name: 'Premium Cotton T-Shirt',
    description: 'High quality cotton t-shirt perfect for everyday wear',
    category: clothing_category,
    brand: nike_brand,
    status: 'active'
  )
  
  # Create product variant
  product.product_variants.create!(
    sku: 'TSHIRT-M-BLUE-001',
    price: 29.99,
    discounted_price: 24.99,
    stock_quantity: 100,
    weight_kg: 0.2
  )
  
  puts "✅ Created sample product: #{product.name}"
end

puts "🎉 Seeding completed!"
puts ""
puts "📋 Login credentials:"
puts "Admin: admin@luxethreads.com / admin123"
puts "Supplier: supplier@example.com / supplier123"
puts "Customer: customer@example.com / customer123"
puts ""
puts "🔗 Access Rails Admin at: http://localhost:3000/admin"
