class Todo < ActiveRecord::Base
    attr_accessible :name, :description, :active, :due, :user_id, :project_id
    validates_uniqueness_of :name, :scope => :user_id, 
      :message => "for this user is already created! (Cant have duplicate Todos)"
      
    belongs_to :user
    belongs_to :project
    validates_associated :project, :user
    validates_presence_of :project, :user

    def to_s
      name
    end
    
    def to_html
      
    end
end
