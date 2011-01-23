class Todo < ActiveRecord::Base
    attr_accessible :name, :description, :active, :due, :user_id, :project_id
    validates_uniqueness_of :name, :scope => :user_id, 
      :message => "for this user is already created! (Cant have duplicate Todos)"
      
    belongs_to :user
    belongs_to :project
    validates_associated :project, :user
    validates_presence_of :project, :user
    validates_inclusion_of :priority, :in => 1..5 ## , :message => "number must be in 1..5!"

    def to_s
      name
    end
    
    def to_html
      
    end
    
    # autodeducts the projects, and other... :)
    def self.magic_create(str)
      # autodetect stuff!
    end
    
    def self.provision_for_user(user)
      ver = '0.1.0'
      tail = "--\nAutoProvisioned Todos v.#{ver}"
      Todo.create([
        { :name => 'personal' , :description => "Your personal stuff"+tail,                   :color => :orange, :user_id => user.id },
        { :name => 'work'     , :description => "Your work or school stuff"+tail,             :color => :green,  :user_id => user.id },
        { :name => 'septober' , :description => "Personal (family, love, hobbies, ...)"+tail, :color => :gray,   :user_id => user.id },
      #  { :name => 'family'   , :description => "AutoProvisioned Projects v.#{ver}", :color => :purple, :user_id => user.id },
      #  { :name => 'love'     , :description => "AutoProvisioned Projects v.#{ver}", :color => :pink,   :user_id => user.id },
      ])
      
    end
end
