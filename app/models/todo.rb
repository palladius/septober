class Todo < ActiveRecord::Base
    attr_accessible :name, :description, :active, :due, :user_id, :project_id
    
    belongs_to :user
    belongs_to :project
    
end
