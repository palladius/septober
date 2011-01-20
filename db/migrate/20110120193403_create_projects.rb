class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string  :name
      t.text    :description
      t.string  :color,       :default => 'grey'
      t.boolean :active,      :default => true
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
