FactoryBot.define do
  factory :pincode_serviceability do
    pincode { '110001' }
    city { 'New Delhi' }
    state { 'Delhi' }
    is_serviceable { true }
    is_cod_available { true }
    standard_delivery_days { 5 }
    express_delivery_days { 2 }
  end
end

