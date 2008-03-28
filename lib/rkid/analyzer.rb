module Rkid
  def self.analyze(&block)
    ActiveRecord::Base.establish_connection YAML::load_file('db/databases.yml')['test']
    coverage_analyzer = Rcov::CodeCoverageAnalyzer.new
    callsite_analyzer = Rcov::CallSiteAnalyzer.new
    
    callsite_analyzer.run_hooked do
      coverage_analyzer.run_hooked do
        yield
      end
    end
    callsite_analyzer.analyzed_classes.each do |klass_name|
      klass = Klass.new(:name => klass_name)
      callsite_analyzer.methods_for_class(klass_name).each do |method_name|
        method = make_method(klass, method_name, callsite_analyzer.defsite(klass_method = klass_name + "#" + method_name))
        callsite_analyzer.callsites(klass_method).each do |site, count|
          make_callsite(method, site)
        end
      end
      klass.save!
    end
    coverage_analyzer.analyzed_files.each do |file_name|
      file = File.new(:name => file_name)
      lines, marked, count = coverage_analyzer.data(file_name)
      lines.each_with_index do |line, i|
        file.lines.build(:body => line, :covered => marked[i], :times_called => count[i])
      end
      file.save!
    end
  end
  
  private
  def self.make_callsite(method, site)
    callsite = method.callsites.build
    site.backtrace.each_with_index do |frame, i|
      callsite.frames.build :line => Line.new(:file => File.new(:name => frame[2]), :number => frame[3])
    end
  end
  
  def self.make_method(klass, method, defsite)
    klass.methods.build(
      :name => method,
      :defsite => Line.new(
        :file => File.new(:name => defsite.file),
        :number => defsite.line
      )
    )
  end
end