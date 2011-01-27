class AddInvisibleToProjects < ActiveRecord::Migration
  
  # Sorry, should call it INVISIBLE but decided to call it visible instead
  # visible means visible in home by default
  def self.up
    add_column :projects, :home_visible, :boolean, :default => true
    add_column :projects, :public,       :boolean, :default => false
  end

  def self.down
    remove_column :projects, :public
    remove_column :projects, :home_visible
  end
end
