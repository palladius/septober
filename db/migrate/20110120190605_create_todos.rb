class CreateTodos < ActiveRecord::Migration
  def self.up
    create_table :todos do |t|
      t.string :name
      t.text :description
      t.bool :active,          :default => true
      t.date :due
      t.integer :user_id
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :todos
  end
end
