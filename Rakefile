require 'rubygems'
require 'rake'
require 'activerecord'
require 'spec'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:coverage) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = ['-x', 'spec,gems']
end

namespace :db do
  require 'sqlite3'
  
  desc 'Build the test databases'
  task :build do
    ActiveRecord::Base.establish_connection YAML::load_file('db/databases.yml')['test']
    load("db/schema.rb")
  end
end

desc "Default task is to run specs"
task :default => :spec
