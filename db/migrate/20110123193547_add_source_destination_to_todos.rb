class AddSourceDestinationToTodos < ActiveRecord::Migration
  def self.up
    add_column :todos, :source, :string
    add_column :todos, :destination, :string
  end

  def self.down
    remove_column :todos, :destination
    remove_column :todos, :source
  end
end
