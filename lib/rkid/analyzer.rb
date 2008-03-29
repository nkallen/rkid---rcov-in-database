module Rkid
  def self.analyze(&block)
    ActiveRecord::Base.establish_connection YAML::load_file('db/databases.yml')['test']
    coverage_analyzer, callsite_analyzer = Rcov::CodeCoverageAnalyzer.new, Rcov::CallSiteAnalyzer.new
    
    callsite_analyzer.run_hooked { coverage_analyzer.run_hooked { yield } }
    analyze_callsite(callsite_analyzer); analyze_coverage(coverage_analyzer)
  end
  
  private
  
  def self.analyze_callsite(callsite_analyzer)
    callsite_analyzer.analyzed_classes.each do |klass_name|
      next if klass_name =~ /Rcov|Rkid/
      
      klass = Klass.new(:name => klass_name)
      callsite_analyzer.methods_for_class(klass_name).each do |method_name|
        defsite = callsite_analyzer.defsite(klass_method = klass_name + "#" + method_name)
        method = klass.methods.build(
          :name => method_name,
          :defsite => make_line(defsite.file, defsite.line)
        )
        
        callsite_analyzer.callsites(klass_method).each do |site, count|
          callsite = method.callsites.build :count => count
          site.backtrace.each_with_index do |frame, i|
            callsite.frames.build :line => make_line(frame[2], frame[3]), :level => i
          end
        end
      end
      klass.save!
    end
  end
  
  def self.analyze_coverage(coverage_analyzer)
    coverage_analyzer.analyzed_files.each do |file_name|
      lines, marked, count = coverage_analyzer.data(file_name)
      lines.each_with_index do |body, i|
        make_line(file_name, i, body, covered = marked[i], times_called = count[i]).save!
      end
    end
  end
  
  def self.make_line(file_name, number, body = nil, covered = nil, times_called = nil)
    file = File.find_or_initialize_by_name(file_name)
    returning file.lines.find_or_initialize_by_number(number) do |line|
      line.attributes = {
        :file => file,
        :number => number,
        :body => body,
        :covered => covered,
        :times_called => times_called
      }
    end
  end
end