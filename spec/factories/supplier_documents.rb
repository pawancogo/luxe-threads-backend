FactoryBot.define do
  factory :supplier_document do
    association :supplier_profile
    document_type { 'gst_certificate' }
    document_url { Faker::Internet.url }
    verification_status { 'pending' }
    
    trait :verified do
      verification_status { 'verified' }
      verified_at { Time.current }
    end
    
    trait :rejected do
      verification_status { 'rejected' }
      rejection_reason { 'Invalid document' }
    end
  end
end

