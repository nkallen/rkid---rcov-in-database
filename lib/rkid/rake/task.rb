require 'rake'
require 'rake/tasklib'

module Rkid
  class Task < Rake::TaskLib
    def initialize
      desc "Run specs with rkid"
      task :rkid do
        rkid_script = ::File.expand_path(::File.dirname(__FILE__) + '/../../../bin/rkid')
        specs = FileList['spec/**/*_spec.rb'].collect { |fn| %["#{fn}"] }.join(' ')
        
        system %(ruby #{rkid_script} `which spec` -- #{specs})
      end
    end
  end
end