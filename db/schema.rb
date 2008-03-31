ActiveRecord::Schema.define do
  create_table :klasses, :force => true do |t|
    t.string :name
  end
  add_index :klasses, :name, :unique => true
  
  create_table :methods, :force => true do |t|
    t.string :name
    t.integer :klass_id, :defsite_id
  end
  add_index :methods, [:klass_id, :name, :defsite_id], :unique => true
    
  create_table :files, :force => true do |t|
    t.string :name
  end
  add_index :files, [:name], :unique => true
    
  create_table :callsites, :force => true do |t|
    t.integer :method_id, :count
  end
    
  create_table :frames, :force => true do |t|
    t.integer :line_id, :callsite_id, :level
  end
  add_index :frames, [:line_id, :callsite_id, :level], :unique => true
    
  create_table :lines, :force => true do |t|
    t.integer :times_called, :method_id, :file_id, :number
    t.boolean :covered
    t.string :body
  end
  add_index :lines, [:file_id, :number], :unique => true
  
end