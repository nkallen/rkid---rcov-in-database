module Rkid
  mattr_accessor :root, :env, :callsite_analyzer, :coverage_analyzer
    
  IGNORE_FILES = [
    /\A#{Regexp.escape(Pathname.new(Config::CONFIG["libdir"]).cleanpath.to_s)}/,
    /\btc_[^.]*.rb/,
    /\bgems\//,
    /\bvendor\//,
    /\A#{Regexp.escape(__FILE__)}\z/
  ]
  
  def self.analyze(&block)
    prepare
    yield
    report
  end
  
  def self.prepare
    self.coverage_analyzer, self.callsite_analyzer = Rcov::CodeCoverageAnalyzer.new, Rcov::CallSiteAnalyzer.new
    callsite_analyzer.install_hook; coverage_analyzer.install_hook
  end
  
  def self.report
    callsite_analyzer.remove_hook; coverage_analyzer.remove_hook
    prepare_connection_to_database
    analyze_callsite(callsite_analyzer); analyze_coverage(coverage_analyzer)
    ActiveRecord::Base.connection.raw_connection.commit
  end
  
  private
  
  def self.prepare_connection_to_database
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => 'rkid.db')
    load ::File.join(root, 'db/schema.rb')
    ActiveRecord::Base.connection.raw_connection.transaction
  end
  
  def self.lines
    @lines ||= Hash.new do |h, (file_name, number)|
      h[[file_name, number]] = Line.create('file_id' => files[file_name].id, 'number' => number)
    end
  end
  
  def self.files
    @files ||= Hash.new do |h, file_name|
      h[file_name] = File.create('name' => file_name)
    end
  end
  
  def self.analyze_callsite(callsite_analyzer)
    total = callsite_analyzer.analyzed_classes.size
    callsite_analyzer.analyzed_classes.each_with_index do |klass_name, i|
      puts "Processing class '#{klass_name}', #{i+1} of #{total}"
      klass = nil
      
      callsite_analyzer.methods_for_class(klass_name).each do |method_name|
        defsite = callsite_analyzer.defsite(klass_method = klass_name + "#" + method_name)
        next if IGNORE_FILES.any? { |pattern| defsite.file =~ pattern }
        
        klass ||= Klass.create('name' => klass_name)
        line = lines[[defsite.file, defsite.line]]
        method = Method.create(
          'klass_id' => klass.id,
          'name' => method_name,
          'defsite_id' => line.id
        )
        callsite_analyzer.callsites(klass_method).each do |site, count|
          callsite = nil
          site.backtrace.each_with_index do |frame, i|
            file_name = frame[2]
            next if IGNORE_FILES.any? { |pattern| file_name =~ pattern }
            
            callsite ||= Callsite.create('method_id' => method.id, 'count' => count)
            line = lines[[file_name, number = frame[3]]]
            Frame.create('callsite_id' => callsite.id, 'line_id' => line.id, 'level' => i)
          end
        end
      end
    end
  end
  
  def self.analyze_coverage(coverage_analyzer)
    coverage_analyzer.analyzed_files.each do |file_name|
      next if IGNORE_FILES.any? { |pattern| file_name =~ pattern }
      
      lines, marked, count = coverage_analyzer.data(file_name)
      lines.each_with_index do |body, i|
        file = File.create('name' => file_name)
        line = Line.create('file_id' => file.id, 'number' => i, 'body' => body, 'covered' => marked[i], 'times_called' => count[i])
      end
    end
  end
end