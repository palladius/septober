class Project < ActiveRecord::Base
    attr_accessible :name, :description, :color, :active, :user_id
end
