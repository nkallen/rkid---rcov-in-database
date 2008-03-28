module Rkid
  class Class < ::ActiveRecord::Base
    has_many :methods
  end

  class Method < ::ActiveRecord::Base
    has_many :callsites
    has_many :lines
    belongs_to :defsite, :class_name => 'Line'
  end

  class File < ::ActiveRecord::Base
    has_many :lines
  end

  class Callsite < ::ActiveRecord::Base
    belongs_to :method
    has_many :frames, :order => :level
    has_many :lines, :through => :frames
  end

  class Frame < ::ActiveRecord::Base
    belongs_to :line
    belongs_to :callsite
  end

  class Line < ::ActiveRecord::Base
    belongs_to :method
    belongs_to :file
  end
end