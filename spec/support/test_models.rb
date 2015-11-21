module FindCacheTest
  class UserDetail < ActiveRecord::Base
    belongs_to :user
  end

  class User < ActiveRecord::Base
    has_one :user_detail
    has_many :posts
    find_cache_has_one :user_detail_cached, FindCacheTest::UserDetail, :user_id
  end
  
  class Post < ActiveRecord::Base
    belongs_to :user, counter_cache: true
    find_cache_belongs_to :user_cached, FindCacheTest::User, :user_id 
  end
end