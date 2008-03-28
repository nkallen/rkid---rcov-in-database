dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

require 'rubygems'
require 'spec'
require 'pp'
require 'rkid'
Dir["#{dir}/matchers/*"].each { |m| require "#{dir}/matchers/#{File.basename(m)}" }

Spec::Runner.configure do |config|  
  config.mock_with :rr
end