# -*- encoding: utf-8 -*-
module FindCache
  # = FindCache ControllerGarbageCollector
  module ControllerGarbageCollector
    extend ActiveSupport::Concern

    included do
      # Garbage collector for current thread
      after_filter :clear_find_cache_store
      
      def clear_find_cache_store
        FindCache::KeyGen.clear_find_cache_store
      end
    end
  end
end
ActionController::Base.send :include, FindCache::ControllerGarbageCollector