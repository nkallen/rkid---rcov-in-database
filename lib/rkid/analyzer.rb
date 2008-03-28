module Rkid
  def self.analyze(&block)
    ActiveRecord::Base.establish_connection YAML::load_file('db/databases.yml')['test']
    coverage = Rcov::CodeCoverageAnalyzer.new
    callsite = Rcov::CallSiteAnalyzer.new
    
    callsite.run_hooked do
      coverage.run_hooked do
        yield
      end
    end
  end
end