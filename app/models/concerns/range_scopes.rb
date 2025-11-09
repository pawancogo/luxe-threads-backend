# frozen_string_literal: true

module RangeScopes
  extend ActiveSupport::Concern

  included do
    scope :within_range, lambda { |start_date, end_date|
      where('( start_date <= ? AND end_date >= ? ) OR ( start_date <= ? AND end_date >= ? ) OR ( start_date >= ? AND end_date <= ? )', start_date, start_date, end_date, end_date, start_date, end_date)
    }
    
    scope :within_date_range, lambda { |start_date, end_date|
      where('created_at >= ? AND created_at <= ?', start_date.beginning_of_day, end_date.end_of_day)
    }
    
    scope :in_price_range, lambda { |min_price, max_price|
      where('price >= ? AND price <= ?', min_price, max_price)
    }
    
    scope :min_price, lambda { |min_price|
      where('price >= ?', min_price) if min_price.present? && min_price.to_f > 0
    }
    
    scope :max_price, lambda { |max_price|
      where('price <= ?', max_price) if max_price.present? && max_price.to_f > 0
    }
  end
end


