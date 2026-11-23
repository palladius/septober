class AddParentIdAndAgentMetadataToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :parent_id,  :integer
    add_column :users, :is_agent,   :boolean, :default => false, :null => false
    add_column :users, :agent_host, :string
    add_column :users, :agent_icon, :string

    add_index :users, :parent_id
    add_index :users, [:parent_id, :is_agent]
  end

  def self.down
    remove_index :users, [:parent_id, :is_agent]
    remove_index :users, :parent_id

    remove_column :users, :agent_icon
    remove_column :users, :agent_host
    remove_column :users, :is_agent
    remove_column :users, :parent_id
  end
end
