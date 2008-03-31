$:.unshift(File.dirname(__FILE__) + "/lib")

require 'rubygems'
require 'rake'
require 'hoe'
require 'activerecord'
require 'spec'
require 'spec/rake/spectask'
require 'rkid'

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Hoe.new('Rkid', Rkid::VERSION) do |p|
  p.name = "Rkid"
  p.author = "Nick Kallen"
  p.description = "Rcov in Database"
  p.email = 'nick@pivotallabs.com'
  p.summary = "Rcov in Database"
  p.url = ""
end

desc "Default task is to run specs"
task :default => :spec
