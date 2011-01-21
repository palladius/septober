class AddFacebookIdAndAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_id, :string
    add_column :users, :admin,       :boolean,       :default => false
    add_column :users, :description, :text
  end

  def self.down
    remove_column :users, :description
    remove_column :users, :admin
    remove_column :users, :facebook_id
  end
end
