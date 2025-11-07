# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Starting to seed the database..."

# Create Categories with hierarchical structure for navigation
puts "Creating categories..."
mens_category = Category.find_or_create_by!(name: "Men") do |cat|
  cat.slug = "men"
  cat.sort_order = 1
end
mens_category.update(slug: "men", sort_order: 1) unless mens_category.slug == "men"

womens_category = Category.find_or_create_by!(name: "Women") do |cat|
  cat.slug = "women"
  cat.sort_order = 2
end
womens_category.update(slug: "women", sort_order: 2) unless womens_category.slug == "women"

# Men's subcategories
mens_subcategories = [
  { name: "Topwear", parent: mens_category },
  { name: "Indian & Festive Wear", parent: mens_category },
  { name: "Bottomwear", parent: mens_category },
  { name: "Men's Footwear", parent: mens_category },
  { name: "Men's Accessories", parent: mens_category }
]

# Women's subcategories
womens_subcategories = [
  { name: "Indian & Fusion Wear", parent: womens_category },
  { name: "Western Wear", parent: womens_category },
  { name: "Women's Footwear", parent: womens_category },
  { name: "Bags & Luggage", parent: womens_category }
]

# Create subcategories for Men
mens_subcategories.each do |subcat_data|
  subcat = Category.find_or_create_by!(name: subcat_data[:name], parent: subcat_data[:parent]) do |cat|
    cat.slug = subcat_data[:name].parameterize
  end
  subcat.update(slug: subcat_data[:name].parameterize) unless subcat.slug == subcat_data[:name].parameterize
end

# Create subcategories for Women
womens_subcategories.each do |subcat_data|
  subcat = Category.find_or_create_by!(name: subcat_data[:name], parent: subcat_data[:parent]) do |cat|
    cat.slug = subcat_data[:name].parameterize
  end
  subcat.update(slug: subcat_data[:name].parameterize) unless subcat.slug == subcat_data[:name].parameterize
end

# Create other root categories
other_categories = [
  { name: "Accessories", slug: "accessories", sort_order: 3 },
  { name: "Shoes", slug: "shoes", sort_order: 4 },
  { name: "Bags", slug: "bags", sort_order: 5 },
  { name: "Jewelry", slug: "jewelry", sort_order: 6 },
  { name: "Watches", slug: "watches", sort_order: 7 },
  { name: "Sunglasses", slug: "sunglasses", sort_order: 8 }
]

other_categories.each do |category_attrs|
  Category.find_or_create_by!(name: category_attrs[:name]) do |cat|
    cat.slug = category_attrs[:slug]
    cat.sort_order = category_attrs[:sort_order]
  end
end

# Create Brands
puts "Creating brands..."
brands_data = [
  { name: "Nike", logo_url: "https://example.com/nike-logo.png" },
  { name: "Adidas", logo_url: "https://example.com/adidas-logo.png" },
  { name: "Zara", logo_url: "https://example.com/zara-logo.png" },
  { name: "H&M", logo_url: "https://example.com/hm-logo.png" },
  { name: "Gucci", logo_url: "https://example.com/gucci-logo.png" },
  { name: "Prada", logo_url: "https://example.com/prada-logo.png" },
  { name: "Levi's", logo_url: "https://example.com/levis-logo.png" },
  { name: "Tommy Hilfiger", logo_url: "https://example.com/tommy-logo.png" },
  { name: "Calvin Klein", logo_url: "https://example.com/ck-logo.png" },
  { name: "Ray-Ban", logo_url: "https://example.com/rayban-logo.png" }
]

brands_data.each do |brand_attrs|
  Brand.find_or_create_by!(name: brand_attrs[:name]) do |brand|
    brand.logo_url = brand_attrs[:logo_url]
  end
end

# Create Shipping Methods
puts "Creating shipping methods..."
shipping_methods = [
  { name: "Standard Shipping", code: "standard", base_charge: 5.00, estimated_days_min: 5, estimated_days_max: 7, is_active: true },
  { name: "Express Shipping", code: "express", base_charge: 15.00, estimated_days_min: 2, estimated_days_max: 3, is_active: true },
  { name: "Overnight Shipping", code: "overnight", base_charge: 25.00, estimated_days_min: 1, estimated_days_max: 1, is_active: true },
  { name: "Free Shipping", code: "free", base_charge: 0.00, estimated_days_min: 7, estimated_days_max: 10, is_active: true }
]

shipping_methods.each do |method_attrs|
  ShippingMethod.find_or_create_by!(code: method_attrs[:code]) do |method|
    method.name = method_attrs[:name]
    method.base_charge = method_attrs[:base_charge]
    method.estimated_days_min = method_attrs[:estimated_days_min]
    method.estimated_days_max = method_attrs[:estimated_days_max]
    method.is_active = method_attrs[:is_active]
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
  admin = Admin.with_deleted.find_by(email: admin_attrs[:email])
  
  if admin
    if admin.deleted?
      admin.restore(recursive: false)
      admin.update!(
        first_name: admin_attrs[:first_name],
        last_name: admin_attrs[:last_name],
        phone_number: admin_attrs[:phone_number],
        password: admin_attrs[:password],
        password_confirmation: admin_attrs[:password],
        role: admin_attrs[:role],
        email_verified: true
      )
    else
      admin.update!(
        first_name: admin_attrs[:first_name],
        last_name: admin_attrs[:last_name],
        phone_number: admin_attrs[:phone_number],
        role: admin_attrs[:role],
        email_verified: true
      )
    end
  else
    Admin.create!(
      first_name: admin_attrs[:first_name],
      last_name: admin_attrs[:last_name],
      email: admin_attrs[:email],
      phone_number: admin_attrs[:phone_number],
      password: admin_attrs[:password],
      password_confirmation: admin_attrs[:password],
      role: admin_attrs[:role],
      email_verified: true
    )
  end
end

# Create Users (Customers) - 20 users for testing dropdown functionality
puts "Creating users..."
users_data = [
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
  },
  {
    first_name: "Alice",
    last_name: "Johnson",
    email: "alice.johnson@example.com",
    phone_number: "+1234567901",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Bob",
    last_name: "Williams",
    email: "bob.williams@example.com",
    phone_number: "+1234567902",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Charlie",
    last_name: "Brown",
    email: "charlie.brown@example.com",
    phone_number: "+1234567903",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Diana",
    last_name: "Prince",
    email: "diana.prince@example.com",
    phone_number: "+1234567904",
    password: "password123",
    role: "premium_customer"
  },
  {
    first_name: "Edward",
    last_name: "Norton",
    email: "edward.norton@example.com",
    phone_number: "+1234567905",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Fiona",
    last_name: "Apple",
    email: "fiona.apple@example.com",
    phone_number: "+1234567906",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "George",
    last_name: "Clooney",
    email: "george.clooney@example.com",
    phone_number: "+1234567907",
    password: "password123",
    role: "vip_customer"
  },
  {
    first_name: "Hannah",
    last_name: "Montana",
    email: "hannah.montana@example.com",
    phone_number: "+1234567908",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Ian",
    last_name: "McKellen",
    email: "ian.mckellen@example.com",
    phone_number: "+1234567909",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Julia",
    last_name: "Roberts",
    email: "julia.roberts@example.com",
    phone_number: "+1234567910",
    password: "password123",
    role: "premium_customer"
  },
  {
    first_name: "Kevin",
    last_name: "Hart",
    email: "kevin.hart@example.com",
    phone_number: "+1234567911",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Lisa",
    last_name: "Simpson",
    email: "lisa.simpson@example.com",
    phone_number: "+1234567912",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Michael",
    last_name: "Jordan",
    email: "michael.jordan@example.com",
    phone_number: "+1234567913",
    password: "password123",
    role: "vip_customer"
  },
  {
    first_name: "Nancy",
    last_name: "Drew",
    email: "nancy.drew@example.com",
    phone_number: "+1234567914",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Oliver",
    last_name: "Twist",
    email: "oliver.twist@example.com",
    phone_number: "+1234567915",
    password: "password123",
    role: "customer"
  },
  {
    first_name: "Patricia",
    last_name: "Cornwell",
    email: "patricia.cornwell@example.com",
    phone_number: "+1234567916",
    password: "password123",
    role: "premium_customer"
  },
  {
    first_name: "Quinn",
    last_name: "Fabray",
    email: "quinn.fabray@example.com",
    phone_number: "+1234567917",
    password: "password123",
    role: "customer"
  }
]

users_data.each do |user_attrs|
  user = User.with_deleted.find_by(email: user_attrs[:email])
  
  if user
    if user.deleted?
      user.restore(recursive: false)
      user.update!(
        first_name: user_attrs[:first_name],
        last_name: user_attrs[:last_name],
        phone_number: user_attrs[:phone_number],
        password: user_attrs[:password],
        password_confirmation: user_attrs[:password],
        role: user_attrs[:role],
        email_verified: true
      )
    else
      user.update!(
        first_name: user_attrs[:first_name],
        last_name: user_attrs[:last_name],
        phone_number: user_attrs[:phone_number],
        role: user_attrs[:role],
        email_verified: true
      )
    end
  else
    User.create!(
      first_name: user_attrs[:first_name],
      last_name: user_attrs[:last_name],
      email: user_attrs[:email],
      phone_number: user_attrs[:phone_number],
      password: user_attrs[:password],
      password_confirmation: user_attrs[:password],
      role: user_attrs[:role],
      email_verified: true
    )
  end
end

# Create Suppliers (as Users with supplier role)
puts "Creating suppliers..."
suppliers_data = [
  {
    first_name: "Supplier",
    last_name: "One",
    email: "supplier1@example.com",
    phone_number: "+1234567893",
    password: "password123",
    role: "supplier"
  },
  {
    first_name: "Supplier",
    last_name: "Two",
    email: "supplier2@example.com",
    phone_number: "+1234567894",
    password: "password123",
    role: "supplier"
  },
  {
    first_name: "Partner",
    last_name: "Supplier",
    email: "partner.supplier@example.com",
    phone_number: "+1234567900",
    password: "password123",
    role: "supplier"
  }
]

suppliers_data.each do |supplier_attrs|
  supplier = User.with_deleted.find_by(email: supplier_attrs[:email])
  
  if supplier
    if supplier.deleted?
      supplier.restore(recursive: false)
      supplier.update!(
        first_name: supplier_attrs[:first_name],
        last_name: supplier_attrs[:last_name],
        phone_number: supplier_attrs[:phone_number],
        password: supplier_attrs[:password],
        password_confirmation: supplier_attrs[:password],
        role: supplier_attrs[:role],
        email_verified: true
      )
    else
      supplier.update!(
        first_name: supplier_attrs[:first_name],
        last_name: supplier_attrs[:last_name],
        phone_number: supplier_attrs[:phone_number],
        role: supplier_attrs[:role],
        email_verified: true
      )
    end
  else
    User.create!(
      first_name: supplier_attrs[:first_name],
      last_name: supplier_attrs[:last_name],
      email: supplier_attrs[:email],
      phone_number: supplier_attrs[:phone_number],
      password: supplier_attrs[:password],
      password_confirmation: supplier_attrs[:password],
      role: supplier_attrs[:role],
      email_verified: true
    )
  end
end

# Create Supplier Profiles
puts "Creating supplier profiles..."
suppliers = User.where(role: "supplier")
supplier_profiles_data = [
  {
    supplier: suppliers.first,
    company_name: "Fashion Forward Ltd",
    gst_number: "GST123456789001",
    description: "Premium fashion supplier specializing in contemporary clothing. We offer the latest trends in men's and women's fashion.",
    website_url: "https://fashionforward.com",
    verified: true
  },
  {
    supplier: suppliers.second,
    company_name: "Style Masters Inc",
    gst_number: "GST987654321002",
    description: "Leading supplier of trendy accessories and footwear. Quality products at competitive prices.",
    website_url: "https://stylemasters.com",
    verified: false
  },
  {
    supplier: suppliers.third,
    company_name: "Elite Fashion Group",
    gst_number: "GST112233445003",
    description: "Premium luxury fashion brand offering high-end clothing and accessories.",
    website_url: "https://elitefashion.com",
    verified: true
  }
]

supplier_profiles_data.each do |profile_attrs|
  # Check if supplier_profile exists for this user
  existing_profile = SupplierProfile.find_by(owner_id: profile_attrs[:supplier].id) || 
                     SupplierProfile.find_by(user_id: profile_attrs[:supplier].id)
  
  if existing_profile
    # Only update fields that won't cause conflicts
    existing_profile.update!(
      company_name: profile_attrs[:company_name],
      description: profile_attrs[:description],
      website_url: profile_attrs[:website_url],
      verified: profile_attrs[:verified]
    ) unless existing_profile.gst_number == profile_attrs[:gst_number]
  else
    # Check if GST number already exists
    gst_exists = SupplierProfile.exists?(gst_number: profile_attrs[:gst_number])
    gst_number = gst_exists ? "#{profile_attrs[:gst_number]}-#{profile_attrs[:supplier].id}" : profile_attrs[:gst_number]
    
    profile = SupplierProfile.create!(
      owner_id: profile_attrs[:supplier].id,
      user_id: profile_attrs[:supplier].id,
      company_name: profile_attrs[:company_name],
      gst_number: gst_number,
      description: profile_attrs[:description],
      website_url: profile_attrs[:website_url],
      verified: profile_attrs[:verified]
    )
    
    # Create supplier account user (owner)
    SupplierAccountUser.find_or_create_by!(
      supplier_profile: profile,
      user: profile_attrs[:supplier]
    ) do |account_user|
      account_user.role = 'owner'
      account_user.status = 'active'
      account_user.can_manage_products = true
      account_user.can_manage_orders = true
      account_user.can_view_financials = true
      account_user.can_manage_users = true
      account_user.can_manage_settings = true
      account_user.can_view_analytics = true
      account_user.accepted_at = Time.current
    end
  end
end

# Create Products - More comprehensive product list
puts "Creating products..."
categories = Category.all
brands = Brand.all
supplier_profiles = SupplierProfile.all

products_data = [
  {
    name: "Classic White T-Shirt",
    description: "Premium cotton t-shirt with a comfortable fit. Made from 100% organic cotton, perfect for everyday wear. Machine washable and colorfast.",
    supplier_profile: supplier_profiles.first,
    category: categories.find_by(name: "Topwear") || categories.first,
    brand: brands.find_by(name: "Nike") || brands.first,
    status: "active"
  },
  {
    name: "Slim Fit Denim Jeans",
    description: "High-quality denim jeans with a modern slim fit. Made from sustainable materials with stretch for comfort. Perfect for casual and semi-formal occasions.",
    supplier_profile: supplier_profiles.first,
    category: categories.find_by(name: "Bottomwear") || categories.first,
    brand: brands.find_by(name: "Levi's") || brands.second,
    status: "active"
  },
  {
    name: "Floral Summer Dress",
    description: "Elegant summer dress perfect for warm weather. Lightweight and breathable fabric with beautiful floral print. Perfect for parties and casual outings.",
    supplier_profile: supplier_profiles.second,
    category: categories.find_by(name: "Western Wear") || categories.second,
    brand: brands.find_by(name: "Zara") || brands.third,
    status: "active"
  },
  {
    name: "Leather Crossbody Handbag",
    description: "Luxury leather handbag with multiple compartments. Handcrafted with attention to detail. Features adjustable strap and secure zipper closure.",
    supplier_profile: supplier_profiles.second,
    category: categories.find_by(name: "Bags") || categories.fifth,
    brand: brands.find_by(name: "Gucci") || brands.fifth,
    status: "active"
  },
  {
    name: "Running Shoes - Air Max",
    description: "High-performance running shoes with advanced cushioning technology. Breathable mesh upper and durable rubber outsole. Perfect for athletes and fitness enthusiasts.",
    supplier_profile: supplier_profiles.first,
    category: categories.find_by(name: "Shoes") || categories.fourth,
    brand: brands.find_by(name: "Nike") || brands.first,
    status: "active"
  },
  {
    name: "Formal White Shirt",
    description: "Crisp white formal shirt with classic collar. Made from premium cotton blend. Perfect for office wear and formal occasions.",
    supplier_profile: supplier_profiles.first,
    category: categories.find_by(name: "Topwear") || categories.first,
    brand: brands.find_by(name: "Tommy Hilfiger") || brands.first,
    status: "active"
  },
  {
    name: "Kurta Set - Festive Collection",
    description: "Traditional Indian kurta set with matching bottoms. Elegant embroidery and premium fabric. Perfect for festivals and special occasions.",
    supplier_profile: supplier_profiles.third,
    category: categories.find_by(name: "Indian & Festive Wear") || categories.first,
    brand: brands.first,
    status: "active"
  },
  {
    name: "Designer Sunglasses",
    description: "Stylish aviator sunglasses with UV protection. Lightweight frame and polarized lenses. Perfect for sunny days and outdoor activities.",
    supplier_profile: supplier_profiles.second,
    category: categories.find_by(name: "Sunglasses") || categories.first,
    brand: brands.find_by(name: "Ray-Ban") || brands.first,
    status: "active"
  },
  {
    name: "Casual Sneakers",
    description: "Comfortable casual sneakers with cushioned insole. Versatile design suitable for everyday wear. Available in multiple colors.",
    supplier_profile: supplier_profiles.first,
    category: categories.find_by(name: "Shoes") || categories.fourth,
    brand: brands.find_by(name: "Adidas") || brands.second,
    status: "active"
  },
  {
    name: "Leather Belt",
    description: "Genuine leather belt with classic buckle. Adjustable sizing and durable construction. Perfect accessory for formal and casual wear.",
    supplier_profile: supplier_profiles.second,
    category: categories.find_by(name: "Accessories") || categories.third,
    brand: brands.find_by(name: "Calvin Klein") || brands.first,
    status: "active"
  },
  {
    name: "Winter Jacket",
    description: "Warm and stylish winter jacket with insulated lining. Water-resistant outer shell. Perfect for cold weather protection.",
    supplier_profile: supplier_profiles.first,
    category: categories.find_by(name: "Topwear") || categories.first,
    brand: brands.find_by(name: "H&M") || brands.first,
    status: "pending"
  },
  {
    name: "Designer Watch",
    description: "Elegant wristwatch with leather strap. Water-resistant and scratch-resistant glass. Perfect for both casual and formal occasions.",
    supplier_profile: supplier_profiles.third,
    category: categories.find_by(name: "Watches") || categories.first,
    brand: brands.first,
    status: "active"
  }
]

products_data.each do |product_attrs|
  Product.find_or_create_by!(name: product_attrs[:name]) do |product|
    product.description = product_attrs[:description]
    product.supplier_profile = product_attrs[:supplier_profile]
    product.category = product_attrs[:category]
    product.brand = product_attrs[:brand]
    product.status = product_attrs[:status]
  end
end

# Create Product Variants with sizes and colors
puts "Creating product variants..."
products = Product.all
sizes = ["XS", "S", "M", "L", "XL", "XXL"]
colors = ["Black", "White", "Navy Blue", "Red", "Gray", "Beige", "Brown"]

products.each do |product|
  # Determine appropriate sizes based on product type
  applicable_sizes = if product.name.downcase.include?("shoes") || product.name.downcase.include?("sneakers")
    ["6", "7", "8", "9", "10", "11"]
  elsif product.name.downcase.include?("watch") || product.name.downcase.include?("belt")
    ["One Size"]
  else
    sizes.sample(rand(3..5))
  end
  
  applicable_colors = if product.name.downcase.include?("white") || product.name.downcase.include?("black")
    [product.name.split.first]
  else
    colors.sample(rand(2..4))
  end
  
  applicable_sizes.each do |size|
    applicable_colors.each do |color|
      sku = "#{product.name.parameterize}-#{size.parameterize}-#{color.parameterize}"
      base_price = rand(500..5000)
      discount_percent = rand(10..40)
      
      ProductVariant.find_or_create_by!(product: product, sku: sku) do |variant|
        variant.price = base_price
        variant.discounted_price = (base_price * (1 - discount_percent / 100.0)).round(2)
        variant.stock_quantity = rand(10..100)
        variant.weight_kg = rand(0.1..2.0).round(2)
        variant.is_available = true
      end
    end
  end
end

# Create Product Images
puts "Creating product images..."
ProductVariant.all.each do |variant|
  # Create 2-4 images per variant
  rand(2..4).times do |index|
    ProductImage.find_or_create_by!(product_variant: variant, display_order: index + 1) do |image|
      image.image_url = "https://picsum.photos/800/800?random=#{variant.id}#{index}"
      image.alt_text = "#{variant.product.name} - Image #{index + 1}"
    end
  end
end

# Note: Attribute Types and Values are automatically seeded via migration
puts "ℹ️  Attribute types and values are automatically seeded during migration"
puts "   #{AttributeType.count} attribute types with #{AttributeValue.count} values available"

# Create Addresses - More addresses for users
puts "Creating addresses..."
User.all.each do |user|
  addresses_data = [
    {
      address_type: "shipping",
      full_name: "#{user.first_name} #{user.last_name}",
      phone_number: user.phone_number,
      line1: "#{rand(100..999)} Main Street",
      line2: "Apt #{rand(1..20)}#{('A'..'Z').to_a.sample}",
      city: ["New York", "Los Angeles", "Chicago", "Houston", "Mumbai", "Delhi"].sample,
      state: ["NY", "CA", "IL", "TX", "MH", "DL"].sample,
      postal_code: rand(10000..99999).to_s,
      country: ["USA", "India"].sample,
      is_default_shipping: true
    },
    {
      address_type: "billing",
      full_name: "#{user.first_name} #{user.last_name}",
      phone_number: user.phone_number,
      line1: "#{rand(100..999)} Oak Avenue",
      line2: "",
      city: ["New York", "Los Angeles", "Chicago", "Houston", "Mumbai", "Delhi"].sample,
      state: ["NY", "CA", "IL", "TX", "MH", "DL"].sample,
      postal_code: rand(10000..99999).to_s,
      country: ["USA", "India"].sample,
      is_default_billing: true
    }
  ]
  
  # Add 1-2 additional addresses for some users
  if rand > 0.5
    addresses_data << {
      address_type: "shipping",
      full_name: "#{user.first_name} #{user.last_name}",
      phone_number: user.phone_number,
      line1: "#{rand(100..999)} Park Road",
      line2: "Building #{rand(1..10)}",
      city: ["New York", "Los Angeles", "Chicago", "Houston", "Mumbai", "Delhi"].sample,
      state: ["NY", "CA", "IL", "TX", "MH", "DL"].sample,
      postal_code: rand(10000..99999).to_s,
      country: ["USA", "India"].sample,
      is_default_shipping: false
    }
  end

  addresses_data.each do |address_attrs|
    Address.find_or_create_by!(
      user: user,
      address_type: address_attrs[:address_type],
      line1: address_attrs[:line1]
    ) do |address|
      address.full_name = address_attrs[:full_name]
      address.phone_number = address_attrs[:phone_number]
      address.line2 = address_attrs[:line2]
      address.city = address_attrs[:city]
      address.state = address_attrs[:state]
      address.postal_code = address_attrs[:postal_code]
      address.country = address_attrs[:country]
      address.is_default_shipping = address_attrs[:is_default_shipping] || false
      address.is_default_billing = address_attrs[:is_default_billing] || false
    end
  end
end

# Create Coupons
puts "Creating coupons..."
coupons_data = [
  {
    code: "WELCOME10",
    name: "Welcome Discount",
    description: "Welcome discount - 10% off on first order",
    coupon_type: "percentage",
    discount_value: 10.0,
    min_order_amount: 500.0,
    max_discount_amount: 500.0,
    max_uses: 1000,
    valid_from: Date.today - 30.days,
    valid_until: Date.today + 30.days,
    is_active: true
  },
  {
    code: "FLAT500",
    name: "Flat ₹500 Off",
    description: "Flat ₹500 off on orders above ₹2000",
    coupon_type: "fixed_amount",
    discount_value: 500.0,
    min_order_amount: 2000.0,
    max_discount_amount: 500.0,
    max_uses: 500,
    valid_from: Date.today - 15.days,
    valid_until: Date.today + 45.days,
    is_active: true
  },
  {
    code: "SUMMER25",
    name: "Summer Sale",
    description: "Summer sale - 25% off on all items",
    coupon_type: "percentage",
    discount_value: 25.0,
    min_order_amount: 1000.0,
    max_discount_amount: 2000.0,
    max_uses: 200,
    valid_from: Date.today,
    valid_until: Date.today + 60.days,
    is_active: true
  }
]

coupons_data.each do |coupon_attrs|
  Coupon.find_or_create_by!(code: coupon_attrs[:code]) do |coupon|
    coupon.name = coupon_attrs[:name]
    coupon.description = coupon_attrs[:description]
    coupon.coupon_type = coupon_attrs[:coupon_type]
    coupon.discount_value = coupon_attrs[:discount_value]
    coupon.min_order_amount = coupon_attrs[:min_order_amount]
    coupon.max_discount_amount = coupon_attrs[:max_discount_amount]
    coupon.max_uses = coupon_attrs[:max_uses]
    coupon.valid_from = coupon_attrs[:valid_from]
    coupon.valid_until = coupon_attrs[:valid_until]
    coupon.is_active = coupon_attrs[:is_active]
  end
end

# Create Carts and Cart Items
puts "Creating carts and cart items..."
User.all.each do |user|
  cart = Cart.find_or_create_by!(user: user)
  
  # Add 2-5 items to cart
  variants = ProductVariant.where(is_available: true).sample(rand(2..5))
  variants.each do |variant|
    CartItem.find_or_create_by!(cart: cart, product_variant: variant) do |item|
      item.quantity = rand(1..3)
    end
  end
end

# Create Wishlists
puts "Creating wishlists..."
User.all.each do |user|
  wishlist = Wishlist.find_or_create_by!(user: user)
  
  # Add 3-8 items to wishlist
  variants = ProductVariant.where(is_available: true).sample(rand(3..8))
  variants.each do |variant|
    WishlistItem.find_or_create_by!(wishlist: wishlist, product_variant: variant)
  end
end

# Create Orders with various statuses
puts "Creating orders..."
customers = User.where(role: ["customer", "premium_customer", "vip_customer"])
product_variants = ProductVariant.where(is_available: true)

customers.each do |customer|
  shipping_address = customer.addresses.find_by(address_type: "shipping") || customer.addresses.first
  billing_address = customer.addresses.find_by(address_type: "billing") || customer.addresses.first
  
  # Create 2-4 orders per customer
  rand(2..4).times do
    order_status = ["pending", "paid", "packed", "shipped", "delivered", "cancelled"].sample
    payment_status = if order_status == "delivered" || order_status == "shipped" || order_status == "packed" || order_status == "paid"
      "payment_complete"
    elsif order_status == "cancelled"
      ["payment_complete", "payment_failed"].sample
    else
      ["payment_pending", "payment_complete"].sample
    end
    
    selected_variants = product_variants.sample(rand(1..4))
    subtotal = selected_variants.sum { |v| v.discounted_price * rand(1..3) }
    shipping_cost = rand(0..25)
    total_amount = subtotal + shipping_cost
    
    order = Order.create!(
      user: customer,
      shipping_address: shipping_address,
      billing_address: billing_address,
      status: order_status,
      payment_status: payment_status,
      shipping_method: ShippingMethod.all.sample&.code || "standard",
      total_amount: total_amount,
      created_at: rand(30.days.ago..Time.current)
    )

    # Create order items
    selected_variants.each do |variant|
      quantity = rand(1..3)
      OrderItem.create!(
        order: order,
        product_variant: variant,
        quantity: quantity,
        price_at_purchase: variant.discounted_price
      )
    end
    
    # Create payment for completed orders
    if payment_status == "payment_complete"
      Payment.create!(
        order: order,
        user: customer,
        amount: total_amount,
        payment_method: ["credit_card", "debit_card", "upi", "cod"].sample,
        status: "completed",
        currency: "INR",
        created_at: order.created_at
      )
    end
    
    # Create shipment for shipped/delivered orders
    if ["shipped", "delivered"].include?(order_status)
      shipment = Shipment.create!(
        order: order,
        tracking_number: "TRK#{rand(1000000..9999999)}",
        carrier: ["FedEx", "UPS", "DHL", "India Post"].sample,
        status: order_status == "delivered" ? "delivered" : "in_transit",
        estimated_delivery_date: order.created_at + rand(2..7).days,
        created_at: order.created_at + rand(1..2).days
      )
      
      # Create tracking events
      if order_status == "delivered"
        ShipmentTrackingEvent.create!(
          shipment: shipment,
          status: "delivered",
          location: shipping_address.city,
          description: "Package delivered successfully",
          occurred_at: shipment.estimated_delivery_date
        )
      end
    end
  end
end

# Create Reviews
puts "Creating reviews..."
customers = User.where(role: ["customer", "premium_customer", "vip_customer"])
delivered_orders = Order.where(status: "delivered")

delivered_orders.each do |order|
  order.order_items.each do |order_item|
    # 70% chance of review
    next unless rand > 0.3
    
    Review.create!(
      user: order.user,
      product: order_item.product_variant.product,
      rating: rand(3..5),
      title: ["Great product!", "Highly recommended", "Good quality", "Worth the price", "Love it!"].sample,
      comment: [
        "Excellent quality and fast delivery. Very satisfied with my purchase!",
        "The product exceeded my expectations. Great value for money.",
        "Good quality material and perfect fit. Would definitely buy again.",
        "Fast shipping and product as described. Happy with the purchase.",
        "Amazing product! The quality is outstanding and delivery was quick."
      ].sample,
      moderation_status: ["approved", "pending"].sample,
      created_at: order.created_at + rand(1..5).days
    )
  end
end

# Create Return Requests
puts "Creating return requests..."
delivered_orders = Order.where(status: "delivered").limit(5)

delivered_orders.each do |order|
  # 30% chance of return request
  next unless rand > 0.7
  
  return_item = order.order_items.sample
  ReturnRequest.create!(
    order: order,
    user: order.user,
    reason: ["Defective product", "Wrong size", "Not as described", "Changed mind"].sample,
    status: ["pending", "approved", "rejected"].sample,
    requested_at: order.created_at + rand(1..7).days
  )
end

# Create Support Tickets
puts "Creating support tickets..."
customers = User.where(role: ["customer", "premium_customer", "vip_customer"])

rand(5..10).times do
  customer = customers.sample
  ticket = SupportTicket.create!(
    user: customer,
    subject: [
      "Order delivery issue",
      "Product quality concern",
      "Payment refund request",
      "Account access problem",
      "Coupon code not working"
    ].sample,
    description: [
      "I haven't received my order yet. It's been more than the estimated delivery time.",
      "The product I received is different from what was shown in the images.",
      "I need a refund for my cancelled order. The payment hasn't been processed yet.",
      "I'm unable to login to my account. Please help.",
      "The coupon code I'm trying to use is showing as invalid."
    ].sample,
    status: ["open", "in_progress", "resolved"].sample,
    priority: ["low", "medium", "high"].sample,
    created_at: rand(30.days.ago..Time.current)
  )
  
  # Add messages to some tickets
  if ticket.status == "in_progress" || ticket.status == "resolved"
    SupportTicketMessage.create!(
      support_ticket: ticket,
      user: Admin.first,
      message: "Thank you for contacting us. We're looking into your issue and will get back to you soon.",
      created_at: ticket.created_at + rand(1..3).hours
    )
  end
end

# Create Notifications
puts "Creating notifications..."
User.all.each do |user|
  notification_types = [
    "order_confirmed",
    "order_shipped",
    "order_delivered",
    "price_drop",
    "new_arrival",
    "promotion"
  ]
  
  rand(3..8).times do
    Notification.create!(
      user: user,
      notification_type: notification_types.sample,
      title: [
        "Your order has been confirmed!",
        "Your order is on the way",
        "Your order has been delivered",
        "Price drop alert!",
        "New arrivals in your favorite category",
        "Special promotion just for you!"
      ].sample,
      message: [
        "Order ##{rand(1000..9999)} has been confirmed and will be processed soon.",
        "Your order is out for delivery. Track it now!",
        "Your order has been successfully delivered. We hope you love it!",
        "The price of items in your wishlist has dropped. Check it out!",
        "New products have been added to categories you love.",
        "Get 20% off on your next purchase. Use code SAVE20."
      ].sample,
      is_read: rand > 0.5,
      created_at: rand(30.days.ago..Time.current)
    )
  end
end

# Create Product Views
puts "Creating product views..."
User.all.each do |user|
  products = Product.where(status: "active").sample(rand(5..15))
  
  products.each do |product|
    ProductView.create!(
      product: product,
      user: user,
      session_id: "session_#{rand(100000..999999)}",
      created_at: rand(30.days.ago..Time.current)
    )
  end
end

# Create User Searches
puts "Creating user searches..."
search_queries = [
  "t-shirt",
  "jeans",
  "dress",
  "shoes",
  "handbag",
  "watch",
  "sunglasses",
  "jacket",
  "kurta",
  "sneakers"
]

User.all.each do |user|
  rand(3..10).times do
    UserSearch.create!(
      user: user,
      search_query: search_queries.sample,
      results_count: rand(10..100),
      searched_at: rand(30.days.ago..Time.current)
    )
  end
end

# Create Loyalty Points Transactions
puts "Creating loyalty points transactions..."
customers = User.where(role: ["customer", "premium_customer", "vip_customer"])

customers.each do |customer|
  # Award points for orders
  customer.orders.where(status: "delivered").each do |order|
    points = (order.total_amount / 10).to_i # 1 point per ₹10 spent
    
    LoyaltyPointsTransaction.create!(
      user: customer,
      transaction_type: "earned",
      points: points,
      description: "Points earned for order ##{order.id}",
      created_at: order.created_at
    )
  end
  
  # Update user's loyalty points
  total_points = customer.loyalty_points_transactions.where(transaction_type: "earned").sum(:points) -
                 customer.loyalty_points_transactions.where(transaction_type: "redeemed").sum(:points)
  customer.update(loyalty_points: [total_points, 0].max)
end

puts "✅ Database seeding completed successfully!"
puts "📊 Summary:"
puts "   - #{Category.count} categories created"
puts "   - #{Brand.count} brands created"
puts "   - #{ShippingMethod.count} shipping methods created"
puts "   - #{Admin.count} admins created"
puts "   - #{User.count} users created"
puts "   - #{User.where(role: 'supplier').count} suppliers created"
puts "   - #{SupplierProfile.count} supplier profiles created"
puts "   - #{Product.count} products created"
puts "   - #{ProductVariant.count} product variants created"
puts "   - #{ProductImage.count} product images created"
puts "   - #{AttributeType.count} attribute types created"
puts "   - #{AttributeValue.count} attribute values created"
puts "   - #{Address.count} addresses created"
puts "   - #{Coupon.count} coupons created"
puts "   - #{Cart.count} carts created"
puts "   - #{CartItem.count} cart items created"
puts "   - #{Wishlist.count} wishlists created"
puts "   - #{WishlistItem.count} wishlist items created"
puts "   - #{Order.count} orders created"
puts "   - #{OrderItem.count} order items created"
puts "   - #{Payment.count} payments created"
puts "   - #{Shipment.count} shipments created"
puts "   - #{Review.count} reviews created"
puts "   - #{ReturnRequest.count} return requests created"
puts "   - #{SupportTicket.count} support tickets created"
puts "   - #{Notification.count} notifications created"
puts "   - #{ProductView.count} product views created"
puts "   - #{UserSearch.count} user searches created"
puts "   - #{LoyaltyPointsTransaction.count} loyalty points transactions created"
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
puts "👤 Customer Logins:"
puts "   Customer:"
puts "     Email: john.doe@example.com"
puts "     Password: password123"
puts "   Premium Customer:"
puts "     Email: jane.smith@example.com"
puts "     Password: password123"
puts "   VIP Customer:"
puts "     Email: vip.customer@example.com"
puts "     Password: password123"
puts ""
puts "🏪 Supplier Logins:"
puts "   Supplier 1:"
puts "     Email: supplier1@example.com"
puts "     Password: password123"
puts "   Supplier 2:"
puts "     Email: supplier2@example.com"
puts "     Password: password123"
puts ""
puts "🎟️  Coupon Codes:"
puts "   - WELCOME10 (10% off, min ₹500)"
puts "   - FLAT500 (₹500 off, min ₹2000)"
puts "   - SUMMER25 (25% off, min ₹1000)"
puts ""
puts "🌐 Access RailsAdmin at: http://localhost:3000/admin"
