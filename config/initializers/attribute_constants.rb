# frozen_string_literal: true

# Attribute Types and Values Constants
# These define all possible product variant attributes (Color, Size, Fabric, etc.)

module AttributeConstants
  # Attribute level definitions
  # PRODUCT_LEVEL: Attributes that apply to the entire product (same for all variants)
  # VARIANT_LEVEL: Attributes that can differ between variants
  ATTRIBUTE_LEVELS = {
    # Product-level attributes (same for all variants)
    product: ['Fabric', 'Material', 'Pattern', 'Style', 'Fit', 'Neckline', 'Sleeve', 'Length', 'Closure', 'Season', 'Occasion', 'Gender', 'Care', 'Weight', 'Type'],
    # Variant-level attributes (can differ per variant)
    variant: ['Color', 'Size']
  }.freeze

  # Attribute Types with their possible values
  ATTRIBUTE_DEFINITIONS = {
    # Color attributes
    'Color' => [
      'Black', 'White', 'Red', 'Blue', 'Green', 'Yellow', 'Orange', 'Purple', 'Pink',
      'Brown', 'Gray', 'Grey', 'Navy', 'Maroon', 'Beige', 'Cream', 'Ivory', 'Gold',
      'Silver', 'Bronze', 'Rose Gold', 'Turquoise', 'Coral', 'Lavender', 'Mint',
      'Teal', 'Olive', 'Burgundy', 'Charcoal', 'Tan', 'Khaki', 'Indigo', 'Violet'
    ],

    # Size attributes
    'Size' => [
      'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL',
      '0', '2', '4', '6', '8', '10', '12', '14', '16', '18', '20', '22', '24',
      '28', '30', '32', '34', '36', '38', '40', '42', '44',
      '6 US', '6.5 US', '7 US', '7.5 US', '8 US', '8.5 US', '9 US', '9.5 US',
      '10 US', '10.5 US', '11 US', '11.5 US', '12 US',
      '36 EU', '37 EU', '38 EU', '39 EU', '40 EU', '41 EU', '42 EU', '43 EU', '44 EU', '45 EU',
      'One Size', 'Free Size', 'OS'
    ],

    # Fabric/Material attributes
    'Fabric' => [
      'Cotton', 'Polyester', 'Silk', 'Wool', 'Linen', 'Denim', 'Leather',
      'Suede', 'Cashmere', 'Chiffon', 'Satin', 'Velvet', 'Brocade', 'Georgette',
      'Rayon', 'Viscose', 'Modal', 'Spandex', 'Elastane', 'Nylon', 'Acrylic',
      'Bamboo', 'Hemp', 'Jute', 'Tencel', 'Lyocell', 'Bamboo Rayon'
    ],

    # Material attributes (for accessories, shoes, etc.)
    'Material' => [
      'Leather', 'Synthetic Leather', 'Canvas', 'Mesh', 'Rubber', 'Silicone',
      'Metal', 'Plastic', 'Wood', 'Glass', 'Ceramic', 'Stainless Steel',
      'Titanium', 'Gold', 'Silver', 'Platinum', 'Brass', 'Copper', 'Aluminum'
    ],

    # Pattern attributes
    'Pattern' => [
      'Solid', 'Striped', 'Polka Dot', 'Floral', 'Geometric', 'Abstract',
      'Checkered', 'Plaid', 'Paisley', 'Animal Print', 'Zebra Print',
      'Leopard Print', 'Tiger Print', 'Camo', 'Tie-Dye', 'Ombre', 'Gradient',
      'Houndstooth', 'Herringbone', 'Argyle', 'Hawaiian', 'Tribal'
    ],

    # Style attributes
    'Style' => [
      'Casual', 'Formal', 'Semi-Formal', 'Party', 'Wedding', 'Business',
      'Sports', 'Vintage', 'Modern', 'Classic', 'Bohemian', 'Gothic',
      'Preppy', 'Streetwear', 'Athletic', 'Bohemian', 'Minimalist', 'Maximalist'
    ],

    # Fit attributes
    'Fit' => [
      'Slim Fit', 'Regular Fit', 'Relaxed Fit', 'Loose Fit', 'Oversized',
      'Skinny', 'Straight', 'Tapered', 'Wide Leg', 'Bootcut', 'Flare',
      'High Waist', 'Low Waist', 'Mid Waist', 'Boyfriend', 'Mom Fit'
    ],

    # Neckline attributes (for tops/dresses)
    'Neckline' => [
      'Round', 'V-Neck', 'Crew Neck', 'Halter', 'Off-Shoulder', 'Boat Neck',
      'Cowl Neck', 'Square Neck', 'Sweetheart', 'Bateau', 'Scoop', 'High Neck',
      'Turtle Neck', 'Mock Neck', 'Collared', 'Hooded'
    ],

    # Sleeve attributes
    'Sleeve' => [
      'Sleeveless', 'Short Sleeve', 'Long Sleeve', 'Three-Quarter Sleeve',
      'Cap Sleeve', 'Raglan Sleeve', 'Bishop Sleeve', 'Bell Sleeve',
      'Puffed Sleeve', 'Kimono Sleeve', 'Flutter Sleeve'
    ],

    # Length attributes
    'Length' => [
      'Mini', 'Above Knee', 'Knee Length', 'Below Knee', 'Mid-Length',
      'Midi', 'Maxi', 'Ankle Length', 'Full Length', 'Cropped', 'High-Low'
    ],

    # Closure attributes
    'Closure' => [
      'Zipper', 'Buttons', 'Snap', 'Hook and Eye', 'Velcro', 'Elastic',
      'Drawstring', 'Belt', 'Magnetic', 'Lace-Up', 'Slip-On', 'No Closure'
    ],

    # Season attributes
    'Season' => [
      'Spring', 'Summer', 'Fall', 'Autumn', 'Winter', 'All Season',
      'Holiday', 'Resort', 'Pre-Fall', 'Pre-Spring'
    ],

    # Occasion attributes
    'Occasion' => [
      'Everyday', 'Work', 'Party', 'Wedding', 'Casual', 'Formal', 'Travel',
      'Beach', 'Outdoor', 'Gym', 'Sports', 'Evening', 'Cocktail', 'Festival'
    ],

    # Gender attributes
    'Gender' => [
      'Men', 'Women', 'Unisex', 'Boys', 'Girls', 'Kids'
    ],

    # Care Instructions attributes
    'Care' => [
      'Machine Wash', 'Hand Wash', 'Dry Clean Only', 'Do Not Wash',
      'Cold Wash', 'Warm Wash', 'Hot Wash', 'Bleach', 'No Bleach',
      'Tumble Dry', 'Air Dry', 'Line Dry', 'No Iron', 'Iron', 'Steam'
    ],

    # Weight attributes (for jewelry/accessories)
    'Weight' => [
      'Light', 'Medium', 'Heavy', 'Ultra Light', 'Standard'
    ],

    # Type attributes (for accessories)
    'Type' => [
      'Stud', 'Hoops', 'Drop', 'Dangle', 'Chandelier', 'Huggie', 'Threader',
      'Cuff', 'Bangle', 'Chain', 'Link', 'Beaded', 'Statement'
    ]
  }.freeze

  # Get all attribute type names
  def self.attribute_type_names
    ATTRIBUTE_DEFINITIONS.keys
  end

  # Get values for a specific attribute type
  def self.values_for(attribute_type_name)
    ATTRIBUTE_DEFINITIONS[attribute_type_name] || []
  end

  # Check if an attribute type exists
  def self.attribute_type_exists?(name)
    ATTRIBUTE_DEFINITIONS.key?(name)
  end

  # Check if a value exists for an attribute type
  def self.value_exists?(attribute_type_name, value)
    values = ATTRIBUTE_DEFINITIONS[attribute_type_name] || []
    values.include?(value)
  end

  # Check if an attribute type is product-level
  def self.product_level?(attribute_type_name)
    ATTRIBUTE_LEVELS[:product].include?(attribute_type_name)
  end

  # Check if an attribute type is variant-level
  def self.variant_level?(attribute_type_name)
    ATTRIBUTE_LEVELS[:variant].include?(attribute_type_name)
  end

  # Get all product-level attribute type names
  def self.product_level_attributes
    ATTRIBUTE_LEVELS[:product]
  end

  # Get all variant-level attribute type names
  def self.variant_level_attributes
    ATTRIBUTE_LEVELS[:variant]
  end

  # Category-specific size mappings
  # This maps category names to appropriate size values
  CATEGORY_SIZE_MAPPINGS = {
    # Clothing categories
    'Clothing' => ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', '0', '2', '4', '6', '8', '10', '12', '14', '16', '18', '20', '22', '24', '28', '30', '32', '34', '36', '38', '40', '42', '44'],
    'Shirts' => ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'],
    'T-Shirts' => ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'],
    'Jeans' => ['28', '30', '32', '34', '36', '38', '40', '42', '44'],
    'Trousers' => ['28', '30', '32', '34', '36', '38', '40', '42', '44'],
    'Dresses' => ['XS', 'S', 'M', 'L', 'XL', 'XXL', '0', '2', '4', '6', '8', '10', '12', '14', '16', '18'],
    'Tops' => ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
    'Skirts' => ['XS', 'S', 'M', 'L', 'XL', 'XXL', '0', '2', '4', '6', '8', '10', '12', '14'],
    
    # Shoe categories
    'Shoes' => ['6 US', '6.5 US', '7 US', '7.5 US', '8 US', '8.5 US', '9 US', '9.5 US', '10 US', '10.5 US', '11 US', '11.5 US', '12 US', '36 EU', '37 EU', '38 EU', '39 EU', '40 EU', '41 EU', '42 EU', '43 EU', '44 EU', '45 EU'],
    'Sneakers' => ['6 US', '7 US', '8 US', '9 US', '10 US', '11 US', '12 US', '36 EU', '37 EU', '38 EU', '39 EU', '40 EU', '41 EU', '42 EU', '43 EU', '44 EU', '45 EU'],
    'Heels' => ['6 US', '6.5 US', '7 US', '7.5 US', '8 US', '8.5 US', '9 US', '9.5 US', '10 US', '36 EU', '37 EU', '38 EU', '39 EU', '40 EU', '41 EU'],
    'Boots' => ['6 US', '7 US', '8 US', '9 US', '10 US', '11 US', '12 US', '36 EU', '37 EU', '38 EU', '39 EU', '40 EU', '41 EU', '42 EU', '43 EU'],
    
    # Accessories (usually one size)
    'Accessories' => ['One Size', 'Free Size', 'OS'],
    'Bags' => ['One Size', 'Free Size', 'OS'],
    'Jewelry' => ['One Size', 'Free Size', 'OS'],
  }.freeze

  # Get size values for a category
  def self.size_values_for_category(category_name)
    return ATTRIBUTE_DEFINITIONS['Size'] if category_name.blank?
    
    # Try exact match first
    return CATEGORY_SIZE_MAPPINGS[category_name] if CATEGORY_SIZE_MAPPINGS.key?(category_name)
    
    # Try parent category or similar matches
    category_name_lower = category_name.downcase
    CATEGORY_SIZE_MAPPINGS.each do |key, values|
      if category_name_lower.include?(key.downcase) || key.downcase.include?(category_name_lower)
        return values
      end
    end
    
    # Default to all sizes if no match
    ATTRIBUTE_DEFINITIONS['Size']
  end
end

