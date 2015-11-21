FactoryGirl.define do
  factory :user, class: FindCacheTest::User do
    sequence :email do |n|
      "person#{n}@example.com"
    end

    password  "12345678"

    after(:create) do |user|
      create(:user_detail, user_id: user.id)
    end

    after(:create) do |user|
      create_list(:post, 5, user: user)
    end
  end
end