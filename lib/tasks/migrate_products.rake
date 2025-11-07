# frozen_string_literal: true

namespace :data do
  desc "Migrate and enhance products data"
  task migrate_products: :environment do
    puts "Migrating products..."
    
    Product.find_each do |product|
      # Update base prices from variants
      if product.product_variants.any?
        prices = product.product_variants.pluck(:price).compact
        if prices.any?
          base_price = prices.min
          base_discounted_price = product.product_variants
            .where.not(discounted_price: nil)
            .pluck(:discounted_price)
            .compact
            .min
          
          product.update_columns(
            base_price: base_price,
            base_discounted_price: base_discounted_price
          )
        end
      end
      
      # Generate slug if missing
      if product.slug.blank? && product.name.present?
        slug = product.name.parameterize
        counter = 1
        while Product.exists?(slug: slug)
          slug = "#{product.name.parameterize}-#{counter}"
          counter += 1
        end
        product.update_column(:slug, slug)
      end
      
      # Update inventory metrics
      total_stock = product.product_variants.sum(:stock_quantity)
      available_stock = product.product_variants.sum(:available_quantity)
      
      product.update_columns(
        total_stock_quantity: total_stock,
        available_stock_quantity: available_stock
      )
    end
    
    puts "✅ Products migration completed!"
  end
end

