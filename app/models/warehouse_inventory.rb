# frozen_string_literal: true

class WarehouseInventory < ApplicationRecord
  self.table_name = 'warehouse_inventory'
  
  belongs_to :warehouse
  belongs_to :product_variant
  
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :warehouse_id, uniqueness: { scope: :product_variant_id }
  
  # Calculate available quantity (SQLite doesn't support generated columns)
  def available_quantity
    stock_quantity - reserved_quantity
  end
  
  def in_stock?
    available_quantity > 0
  end
  
  def low_stock?(threshold = 10)
    available_quantity <= threshold
  end
end

