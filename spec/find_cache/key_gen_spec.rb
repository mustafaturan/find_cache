require 'spec_helper'

describe FindCache::KeyGen do
  let(:model_name) { 'User' }
  describe '.cache_key' do
    it 'generate cache key' do
      id = 1
      expect(FindCache::KeyGen.cache_key("#{model_name}", id)).to eq "#{model_name}/#{id}"
    end
  end

  describe '.cache_key_ref' do
    it 'generate ref cache key' do
      fk = 'UserDetail'
      fk_id = '1'
      expect(FindCache::KeyGen.cache_key_ref(model_name, fk, fk_id)).to eq "#{model_name}/#{fk}-#{fk_id}"
    end
  end

  describe '.global_cache_key' do
    it 'generates global cache key' do
      expect(FindCache::KeyGen.global_cache_key).to_not eq nil
    end

    it 'clears global cache key' do
      FindCache::KeyGen.global_cache_key
      expect(FindCache::KeyGen.global_cache_key(true)).to eq nil
    end
  end

  describe '.clear_find_cache_store' do
    it 'clears find cache store' do
      key = FindCache::KeyGen.global_cache_key
      $find_cache_store[key] = { tmp: 'sth' }
      FindCache::KeyGen.clear_find_cache_store
      expect($find_cache_store.has_key?(key)).to eq false
      expect(FindCache::KeyGen.global_cache_key).to_not eq key
    end
  end
end
