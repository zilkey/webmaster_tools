ActiveRecord::Schema.define(:version => 0) do
  create_table :wynkens, :force => true do |t|
     t.string :name
  end
  create_table :blinkens, :force => true do |t|
     t.string :name
     t.timestamps
  end
  create_table :nods, :force => true do |t|
     t.string :name
     t.string :changefreq
     t.string :priority
     t.string :lastmod
     t.timestamps
  end
end
