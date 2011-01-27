class AddStuffToTodosAgain < ActiveRecord::Migration
  def self.up
    add_column :todos, :url, :string
    add_column :todos, :depends_on_id, :integer  # another todo, this yeilds to complications!
    #add_column :todos, :recurs, :datetime  # another todo, this yeilds to complications!
  end

  def self.down
    remove_column :todos, :depends_on_id
    remove_column :todos, :url
  end
end
