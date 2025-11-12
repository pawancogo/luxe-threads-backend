# frozen_string_literal: true

# Service for providing available filter options for public products
module Products
  class PublicFiltersService < BaseService
    attr_reader :filters

    def call
      calculate_filters
      set_result(@filters)
      self
    rescue StandardError => e
      handle_error(e)
      self
    end

    private

    def calculate_filters
      @filters = {
        price_range: calculate_price_range,
        categories: calculate_categories,
        brands: calculate_brands,
        sort_options: sort_options,
        flags: product_flags
      }
    end

    def calculate_price_range
      {
        min: ProductVariant.minimum(:discounted_price) || ProductVariant.minimum(:price) || 0,
        max: ProductVariant.maximum(:discounted_price) || ProductVariant.maximum(:price) || 10000
      }
    end

    def calculate_categories
      Category.all.map { |c| { id: c.id, name: c.name, slug: c.slug } }
    end

    def calculate_brands
      Brand.active.map { |b| { id: b.id, name: b.name, slug: b.slug } }
    end

    def sort_options
      [
        { value: 'recommended', label: 'Recommended' },
        { value: 'price_low_high', label: 'Price: Low to High' },
        { value: 'price_high_low', label: 'Price: High to Low' },
        { value: 'newest', label: 'Newest First' },
        { value: 'oldest', label: 'Oldest First' },
        { value: 'rating', label: 'Highest Rated' },
        { value: 'popular', label: 'Most Popular' },
        { value: 'name_asc', label: 'Name: A to Z' },
        { value: 'name_desc', label: 'Name: Z to A' }
      ]
    end

    def product_flags
      [
        { key: 'featured', label: 'Featured' },
        { key: 'bestseller', label: 'Bestseller' },
        { key: 'new_arrival', label: 'New Arrival' },
        { key: 'trending', label: 'Trending' }
      ]
    end
  end
end

