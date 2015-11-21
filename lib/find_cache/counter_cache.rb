# -*- encoding: utf-8 -*-
module FindCache
  # = FindCache ControllerGarbageCollector
  module CounterCache
    extend ActiveSupport::Concern
    module ClassMethods
      def update_counters(id, counters)
        super
        expire_find_cache(id)
      end
    end
  end
end
ActiveRecord::Base.send :include, FindCache::CounterCache