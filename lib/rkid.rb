$LOAD_PATH.unshift(File.dirname(__FILE__))

module Rkid
  VERSION = '0.1'
end

require 'rubygems'
require 'activesupport'
require 'activerecord'
require 'rcov'
require 'sqlite3'
require 'rbconfig'

require 'rkid/analyzer'
require 'rkid/models'

Rkid.root = File.join(File.dirname(__FILE__), '..')