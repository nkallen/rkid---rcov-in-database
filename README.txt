Rkid is Rcov In Database

WHAT

Rkid is a tool to surface RCov coverage and callsite data in a relational database. It also provides a friendly ActiveRecord model so you can easily query the data.


WHY

I want to ask questions of my codebase:

* What classes are abstract?
* Who calls method #x?
* What coverage does this little unit test have?
* What classes of objects are passed into #x?
* What classes does class A collaborate with?
  * which collaborators are manufactured by class A?
  * which collaborators in injected into class A?
  * what implicit interfaces/protocols does A rely on?
* What implicit interfaces exist in my system (e.g., methods in different class hierarchies invoked from the same callsites)
* etc.

WARNING

Rkid provides a rake task to run your spec suite with rcov turned on. Unlike *normal* rake spec:rcov, I turn on the callsite information. This is the data the illustrates, e.g., who calls what methods; what lines of code one individual test covers; and so forth.

Please note that Rkid is slow. But don't complain: I've optimized from 16 hours down to 1.5 minutes on a sample project. But don't get too excited: because the sample project normally runs 300 specs in 3 seconds. Rkid is currently too slow to run on a Rails app. Don't even bother trying unless you're developing on a Cray.

DEPENDENCIES

* Rspec-based test suite
* Sqlite3

USAGE

Install the gem from rubyforge

   gem install rkid

Add these lines to your rakefile:

    require 'rkid/rake/task'
    Rkid::Task.new
    
Then, execute this on the command line:

    rake rkid

Finally, Query the data like this:

    require 'rubygems'
    require 'activerecord'
    require 'rkid'
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => 'rkid.db')
    Rkid::Klass.find(:all)

And so forth.