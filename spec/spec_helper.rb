FILE_ROOT=File.join(File.dirname(__FILE__), '../')
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'find_cache'
require 'active_record'
require 'factory_girl'
require 'database_cleaner'
require 'rails_helper'
Dir[File.join(FILE_ROOT, "spec/support/*.rb")].each {|f| require f }
Dir[File.join(FILE_ROOT, "spec/factories/*.rb")].each {|f| require f }

ActiveRecord::Migrator.up('spec/db/migrate')