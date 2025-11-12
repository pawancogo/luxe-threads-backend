FactoryBot.define do
  factory :warehouse_inventory do
    association :warehouse
    association :product_variant
    quantity { 100 }
    reserved_quantity { 0 }
    available_quantity { 100 }
  end
end





