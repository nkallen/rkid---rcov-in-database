require 'rubygems'
require 'rake'
require 'activerecord'

namespace :db do
  require 'sqlite3'
  
  desc 'Build the test databases'
  task :build do
    ActiveRecord::Base.establish_connection YAML::load_file('db/databases.yml')['test']
    load("db/schema.rb")
  end
end