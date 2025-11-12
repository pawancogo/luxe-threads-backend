FactoryBot.define do
  factory :shipment_tracking_event do
    association :shipment
    status { 'in_transit' }
    event_time { Time.current }
    location { 'Mumbai' }
    description { 'Package in transit' }
  end
end





