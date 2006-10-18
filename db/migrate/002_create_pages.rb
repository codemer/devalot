################################################################################
class CreatePages < ActiveRecord::Migration
  ################################################################################
  def self.up
    ################################################################################
    create_table :pages do |t|
      t.column :project_id, :integer
      t.column :title,      :string
      t.column :body,       :text
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end

    add_index(:pages, [:project_id, :title], :unique => true)
  end

  ################################################################################
  def self.down
    drop_table(:pages)
  end

end
################################################################################