# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 1) do
  create_table "articles", :force => true do |t|
    t.column "title", :string, :default => "", :null => false
    t.column "description", :text, :default => "", :null => false
    t.column "lastupdate", :date
  end
end