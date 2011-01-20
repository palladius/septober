class Todo < ActiveRecord::Base
    attr_accessible :name, :description, :active, :due, :user_id, :project_id
end
