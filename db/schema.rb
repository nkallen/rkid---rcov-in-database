ActiveRecord::Schema.define do
  create_table :klasses, :force => true do |t|
    t.string :name
  end
  
  create_table :methods, :force => true do |t|
    t.string :name
    t.integer :klass_id, :defsite_id
  end
  
  create_table :files, :force => true do |t|
    t.string :name
  end
  
  create_table :callsites, :force => true do |t|
    t.integer :method_id, :count
  end
  
  create_table :frames, :force => true do |t|
    t.integer :line_id, :callsite_id, :level
  end
  
  create_table :lines, :force => true do |t|
    t.integer :times_called, :method_id, :file_id, :number
    t.boolean :covered
    t.string :body
  end
end