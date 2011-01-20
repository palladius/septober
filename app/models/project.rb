class Project < ActiveRecord::Base
    attr_accessible :name, :description, :xolor, :active, :user_id
end
