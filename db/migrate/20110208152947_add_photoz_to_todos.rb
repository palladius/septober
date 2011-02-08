class AddPhotozToTodos < ActiveRecord::Migration
  def self.up
    add_column :todos, :photo_url, :string
  end

  def self.down
    remove_column :todos, :photo_url
  end
end
