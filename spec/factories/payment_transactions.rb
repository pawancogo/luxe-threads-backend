FactoryBot.define do
  factory :payment_transaction do
    association :payment
    transaction_id { "TXN-#{SecureRandom.hex(8).upcase}" }
    transaction_type { 'payment' }
    amount { 100.0 }
    status { 'success' }
  end
end

