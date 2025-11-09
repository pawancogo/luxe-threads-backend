FactoryBot.define do
  factory :shipment do
    association :order
    shipment_id { "SHIP-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}" }
    from_address { { city: 'Mumbai', state: 'Maharashtra' }.to_json }
    to_address { { city: 'Delhi', state: 'Delhi' }.to_json }
    status { 'pending' }
    tracking_number { "TRACK#{SecureRandom.hex(4).upcase}" }
    
    trait :shipped do
      status { 'in_transit' }
      shipped_at { Time.current }
    end
    
    trait :delivered do
      status { 'delivered' }
      delivered_at { Time.current }
    end
  end
end

