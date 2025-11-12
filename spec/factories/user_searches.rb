FactoryBot.define do
  factory :user_search do
    association :user, optional: true
    search_query { 'test query' }
    source { 'search_bar' }
    searched_at { Time.current }
    results_count { 10 }
    filters { { category: 'electronics' }.to_json }
  end
end





