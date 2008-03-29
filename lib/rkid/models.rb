module Rkid
  class Klass < ::ActiveRecord::Base
    # validates_uniqueness_of :name
    has_many :methods, :class_name => 'Method', :dependent => :destroy
  end

  class Method < ::ActiveRecord::Base
    belongs_to :klass
    has_many :callsites, :dependent => :destroy
    has_many :lines, :dependent => :destroy
    belongs_to :defsite, :class_name => 'Line'
  end

  class File < ::ActiveRecord::Base
    has_many :lines, :order => :number, :dependent => :destroy
  end

  class Callsite < ::ActiveRecord::Base
    belongs_to :method
    has_many :frames, :order => :level, :dependent => :destroy
    has_many :lines, :through => :frames, :dependent => :destroy
  end

  class Frame < ::ActiveRecord::Base
    belongs_to :callsite
    belongs_to :line
    belongs_to :callsite
  end

  class Line < ::ActiveRecord::Base
    belongs_to :method
    belongs_to :file
  end
end