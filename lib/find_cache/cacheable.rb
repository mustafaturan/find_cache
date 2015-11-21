# -*- encoding: utf-8 -*-
module FindCache

  # = FindCache Cachable
  module Cacheable
    extend ActiveSupport::Concern
    
    module ClassMethods
      # has_one relational caching with find_cache
      #
      # ==== Parameters
      #
      # * +attribute+ - The attribute that you wish to name for cache
      # * +model+ - The Model which data will be retreived for caching
      # * +foreign_key+ - The FK attribute name in the given Model
      #
      # ==== Examples
      #
      #   # For User model with user_id ForeignKey in UserDetail model
      #   find_cache_has_one :user_detail, UserDetail, :user_id
      def find_cache_has_one(attribute, model, foreign_key)
        send :define_method, attribute.to_sym do
          model.find_cache_by_ref(foreign_key, self.send(self.class.primary_key.to_sym))
        end
      end

      # belongs_to relational caching with find_cache
      #
      # ==== Parameters
      #
      # * +attribute+ - The attribute that you wish to name for cache
      # * +model+ - The Model which data will be retreived for caching
      # * +foreign_key+ - The FK attribute name of given Model for the current Model
      #
      # ==== Examples
      #
      #   # In UserDetail model with user_id ForeignKey of User model
      #   find_cache_belongs_to :user, User, :user_id
      def find_cache_belongs_to(attribute, model, foreign_key)
        send :define_method, attribute.to_sym do
          model.find_cache(self.send(foreign_key.to_sym))
        end
      end

      # To find an Active Record object using PK (:id) based where
      # query method and caching it using Rails.cache methods
      #
      # ==== Parameters
      #
      # * +id+ - Id for the model
      #
      # ==== Examples
      #
      #   # Find a User object with id 1 from User model
      #   User.find_cache(1)  
      def find_cache(id)
        key = KeyGen.cache_key(name, id)
        $find_cache_store[KeyGen.global_cache_key][key] ||= (
          Rails.cache.fetch(key) do
            where(primary_key => id).limit(1).first
          end
        )
      end

      # To find an Active Record object using attributes other than
      # primary key (:id) and caching it using Rails.cache methods
      #
      # ==== Parameters
      #
      # * +ref_attr+ - Reference attribute which will be looked in table
      # * +ref_value+ - Value for the given referenced attribute
      #
      # ==== Examples
      #
      #   # Find an UserDetail object using user_id attribute with value 1
      #   UserDetail.find_cache_by_ref(:user_id, 1)
      def find_cache_by_ref(ref_attr, ref_val)
        key_ref = KeyGen.cache_key_ref(name, ref_attr, ref_val)
        if (id = Rails.cache.read(key_ref))
          find_cache(id)
        else
          item = where(ref_attr => ref_val).limit(1).first
          if item
            Rails.cache.write(key_ref, item.send(primary_key.to_sym))
            Rails.cache.write(KeyGen.cache_key(name, item.send(primary_key.to_sym)), item)
          end
          item
        end
      end

      # To find all Active Record objects using id list
      #
      # ==== Parameters
      #
      # * +ids+ - List of ids 
      # * +order_by+ - optional order direction for results
      #
      # ==== Notes
      #   # Only valid if the Rails.cache store supports read_multi
      #
      # ==== Examples
      #
      #   # Find users with ids ([21, 1, 2, 19, 43]) from User model
      #   UserDetail.find_all_cache([21, 1, 2, 19, 43])
      #   # Find users with ids ([21, 1, 2, 19, 43]) and id ASC
      #   UserDetail.find_all_cache(([21, 1, 2, 19, 43]), "id ASC")
      def find_all_cache(ids, order_by = "#{primary_key} DESC")
        all_new_cache = []
        not_in_cache  = []
        cache_ids = ids.map { |id| KeyGen.cache_key(name, id) }
        all_cache = Rails.cache.read_multi(cache_ids)
        cache_ids.each_with_index do |cache_id, cache_id_index|
          if all_cache[cache_id]
            all_new_cache << all_cache[cache_id]
          else
            not_in_cache << ids[cache_id_index]
          end
        end
        if not_in_cache.length > 0
          items = order(order_by).where(primary_key => not_in_cache)
          items.each do |item|
            Rails.cache.write(KeyGen.cache_key(name, item.send(primary_key.to_sym)), item)
          end
          all_new_cache += items
        end
        all_new_cache.each do |cached_item|
          $find_cache_store[KeyGen.global_cache_key][KeyGen.cache_key(name, cached_item.send(primary_key.to_sym))] = cached_item
        end
        order_attr, order_direction = order_by.split(' ')
        ordered_cache = all_new_cache.sort_by { |item| item.send(order_attr) }
        order_direction.eql?('DESC') ? ordered_cache.reverse : ordered_cache 
      end

      # Expire cache for given name and pk val
      #
      # ==== Parameters
      #
      # * +pk_val+ - pk val
      #
      def expire_find_cache(pk_val)
        key = KeyGen.cache_key(name, pk_val)
        Rails.cache.delete(key)
        $find_cache_store[KeyGen.global_cache_key].delete(key)
      end
    end

    included do
      after_save :expire_find_cache
      after_destroy :expire_find_cache

      # Expires the cache on reload
      #
      def reload
        expire_find_cache
        super
      end

      # Expires the cache
      #      
      def expire_find_cache
        return if self.class.primary_key.blank?
        self.class.expire_find_cache(
          self.send(self.class.primary_key.to_sym)
        )
      end
    end
  end
end

ActiveRecord::Base.send :include, FindCache::Cacheable