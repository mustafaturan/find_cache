require 'logger'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3', database: ':memory:'
)

#this line will print the SQL queries right into console 
ActiveRecord::Base.logger = Logger.new(STDOUT)