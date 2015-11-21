FactoryGirl.define do
  factory :user_detail, class: FindCacheTest::UserDetail do
    #association :user, factory: :user
    user_id 1
    sequence :first_name do |n|
      "f#{n}"
    end
    sequence :last_name do |n|
      "s#{n}"
    end
    admin false
  end
end