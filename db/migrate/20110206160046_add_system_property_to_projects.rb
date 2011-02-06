class AddSystemPropertyToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :system, :boolean, :default => false   # what a user creates is NOT system..
    add_column :projects, :photo_url, :string
    Project.find(:all).each do |project|
      if project.name.match /^(personal|septober|work)$/
        puts "Fixing :system and :photo_url for project '#{project}' by\t'#{project.user}'.."
        project.system = true 
        project.photo_url = "#{project.name}.png"
        project.save
      end
    end
  end

  def self.down
    remove_column :projects, :photo_url # rescue "Maybe there isnt yet... no worries 2"
    remove_column :projects, :system    # rescue 'Chissene'
  end
end
