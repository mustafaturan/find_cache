# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
abort("The Rails environment is running in production mode!") if Rails.env.production?

Rails.cache = ActiveSupport::Cache::MemoryStore.new