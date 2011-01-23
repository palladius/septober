class AddSourceDestinationToTodos < ActiveRecord::Migration
  def self.up
    add_column :todos, :source, :string, :default => 'web'
    add_column :todos, :where, :string
  end

  def self.down
    remove_column :todos, :where
    remove_column :todos, :source
  end
end
