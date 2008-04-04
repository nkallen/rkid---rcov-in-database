module Rkid
  module FastCreate
    def db
      ActiveRecord::Base.connection.raw_connection
    end
    
    def create(attributes)
      insert = db.prepare <<-SQL
        INSERT INTO #{table_name}
        (#{attributes.keys.join(', ')}) VALUES (#{attributes.keys.collect { |c| ":#{c}" }.join(', ')})
      SQL
      insert.execute attributes
      instantiate(attributes.merge('id' => db.last_insert_row_id))
    end
  end
  
  class Klass < ::ActiveRecord::Base
    extend FastCreate
    
    has_many :methods, :class_name => 'Method', :dependent => :destroy
  end

  class Method < ::ActiveRecord::Base
    extend FastCreate

    belongs_to :klass
    has_many :callsites, :dependent => :destroy
    has_many :lines, :dependent => :destroy
    belongs_to :defsite, :class_name => 'Line'
  end

  class File < ::ActiveRecord::Base
    extend FastCreate

    has_many :lines, :order => :number, :dependent => :destroy
    
    def self.update(attributes)
      find_by_name(attributes['name'])
    end
  end

  class Callsite < ::ActiveRecord::Base
    extend FastCreate

    belongs_to :method
    has_many :frames, :order => :level, :dependent => :destroy
    has_many :lines, :through => :frames, :dependent => :destroy
  end

  class Frame < ::ActiveRecord::Base
    extend FastCreate

    belongs_to :callsite
    belongs_to :line
  end

  class Line < ::ActiveRecord::Base
    extend FastCreate

    belongs_to :method
    belongs_to :file
    
    def self.update(line, attributes)
      assignments = attributes.keys.collect do |key|
        "#{key} = :#{key}"
      end.join ', '
      update = db.prepare <<-SQL
        UPDATE #{table_name} SET
        #{assignments}
        WHERE id = :id
      SQL
      update.execute attributes.merge('id' => line.id)
      line.attributes = attributes
      line
    end
  end
end