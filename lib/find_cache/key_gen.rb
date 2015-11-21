# -*- encoding: utf-8 -*-
module FindCache
  # = FindCache KeyGen
  class KeyGen
    
    # cache_key generator for model items
    #
    # ==== Parameters
    #
    # * +model_name+ - The name of the model
    # * +id+ - Id for the given model
    #
    # ==== Examples
    #
    #   FindCache::KeyGen.cache_key("User", 1)
    def self.cache_key(model_name, id)
      "#{model_name}/#{id}"
    end
    
    # cache_key generator for model items with referenced attribute
    #
    # ==== Parameters
    #
    # * +model_name+ - The name of the model
    # * +foreign_key_name+ - Name of the foreign_key attribute
    # * +foreign_key_id+ - Id for the given foreign_key name
    #
    # ==== Examples
    #
    #   FindCache::KeyGen.cache_key_ref("UserDetail", "user_id", 1)
    def self.cache_key_ref(model_name, foreign_key_name, foreign_key_id)
      "#{model_name}/#{foreign_key_name}-#{foreign_key_id}"
    end
    
    # cache_key generator for the current thread
    #
    # ==== Parameters
    #
    # * +clear+ - Boolean value to clean up the current Thread's cache key
    #
    # ==== Examples
    #
    #   # For generating cache key for the current Thread
    #   FindCache::KeyGen.global_cache_key
    #   # For cleaning generated cache key for the current Thread
    #   FindCache::KeyGen.global_cache_key(true)
    def self.global_cache_key(clear = false)
      return (Thread.current[:global_cache_key] = nil) if clear
      Thread.current[:global_cache_key] ||= generate_uuid_and_init_cache_hash
    end

    # Cleaning all caches of the current Thread not the Rails.cache
    #
    def self.clear_find_cache_store
      $find_cache_store.delete(KeyGen.global_cache_key)
      KeyGen.global_cache_key(true)
    end
    
    private
    #nodoc
    def self.generate_uuid_and_init_cache_hash
      uuid = SecureRandom.uuid.gsub('-', '')
      $find_cache_store[uuid] = {}
      uuid
    end
  end
end