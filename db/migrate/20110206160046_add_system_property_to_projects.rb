class AddSystemPropertyToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :system, :boolean, :default => false   # what a user creates is NOT system..
    Project.find(:all).each do |project|
      if project.name.match /^(personal|septober|work)$/
        puts "Setting system=true for project '#{project}' by '#{project.user}'.."
        project.system = true 
        project.save
      end
    end
  end

  def self.down
    remove_column :projects, :system
  end
end
