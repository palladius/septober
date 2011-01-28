class AddHideUntilToTodo < ActiveRecord::Migration
  def self.up
    add_column :todos, :hide_until,      :datetime
    add_column :todos, :progress_status, :integer, :default => 0       # Completion status of this task 0..100
    add_column :todos, :favorite,        :boolean, :default => false   # Marks a todo with a star
  end

  def self.down
    remove_column :todos, :favorite
    remove_column :todos, :progress_status
    remove_column :todos, :hide_until
  end
end
