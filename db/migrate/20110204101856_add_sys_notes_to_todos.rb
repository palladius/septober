class AddSysNotesToTodos < ActiveRecord::Migration
  def self.up
    add_column :todos, :sys_notes, :text
  end

  def self.down
    remove_column :todos, :sys_notes
  end
end
