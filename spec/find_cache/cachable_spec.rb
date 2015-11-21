require 'spec_helper'

describe FindCache::Cacheable do
  let(:user) { create(:user) }
  
  before(:each) do
    Rails.cache.clear
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  after(:each) do
    DatabaseCleaner.clean
  end

  describe '.find_cache' do
    it 'fetch(read/write) from cache' do
      expect(FindCacheTest::User.find_cache(user.id).email).to eq user.email
    end
  
    it 'expires cache on update' do
      new_email_address = "new@example.com"
      FindCacheTest::User.find_cache(user.id) # write to cache
      user.update_attribute(:email, new_email_address)
      expect(FindCacheTest::User.find_cache(user.id).email).to eq new_email_address
    end

    it 'expires cache on destroy' do
      FindCacheTest::User.find_cache(user.id) # write to cache
      user.destroy
      expect(FindCacheTest::User.find_cache(user.id)).to eq nil
    end
  end

  describe '.find_cache_has_one' do
    it 'fetch(read/write) from cache has_one' do
      user.user_detail_cached # write to cache
      expect(user.user_detail_cached.id).to eq user.user_detail.id
      expect(user.user_detail_cached.first_name).to eq user.user_detail.first_name
      expect(user.user_detail_cached.last_name).to eq user.user_detail.last_name
    end
  
    it 'expires has_one cache on update' do
      cached = user.user_detail_cached # cache
      cached.update_attribute(:first_name, 'Test')
      expect(user.user_detail_cached.first_name).to eq user.user_detail.first_name
    end
  
    it 'expires cache on delete' do
      user.user_detail_cached # write to cache
      user.user_detail.destroy # should delete cache too
      expect(user.user_detail_cached).to eq nil
    end
  end

  describe '.find_cache_belongs_to' do
    it 'fetch(read/write) from cache belongs_to' do
      post = user.posts.last
      expect(post.user_cached.email).to eq user.email
    end

    it 'expires belongs_to cache on update' do
      new_email_address = "new@example.com"
      post = user.posts.last
      post.user_cached # write to cache belongs_to
      user.update_attribute(:email, new_email_address)
      expect(post.user_cached.email).to eq new_email_address
    end
    
    it 'counter_cache test' do
      expect(FindCacheTest::User.find_cache(user.id).posts_count).to eq 5
      FindCacheTest::User.find_cache(user.id).posts.last.destroy
      expect(FindCacheTest::User.find_cache(user.id).posts_count).to eq 4
    end
  end

  describe '.find_cache_by_ref' do
    it 'finds cached content from ref key' do
      user.user_detail.update_attribute(:first_name, 'TEST')
      expect(FindCacheTest::UserDetail.find_cache_by_ref(:user_id, user.id).first_name).to eq 'TEST'
    end
  end

  describe '.find_all_cache' do
    it 'fetch(read/write) for multiple ids' do
      post_ids = user.posts.pluck(:id)
      expect(FindCacheTest::Post.find_all_cache(post_ids)).to eq user.posts.order(id: :desc)
      FindCacheTest::Post.find_all_cache(post_ids)
    end
  end

  describe '#reload' do
    it 'clears cache on reload' do
      expect(FindCacheTest::User.find_cache(user.id).posts_count).to eq 5
      FindCacheTest::User.find_cache(user.id).posts.last.destroy
      user.reload
      expect(FindCacheTest::User.find_cache(user.id).posts_count).to eq 4
    end
  end
end
