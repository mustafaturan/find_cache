FactoryGirl.define do
  factory :post, class: FindCacheTest::Post do
    association :user, factory: :user
    sequence :title do |n|
      "Title#{n}"
    end
    body  "I am a test body."
  end
end