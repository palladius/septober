class Project < ActiveRecord::Base
    attr_accessible :name, :description, :color, :active, :user_id
    # only one 'personal' of a name per user..
    validates_format_of :name, :with => /^[a-z_]+$/, :message => "is invalid (only lowercase letters and _)"
    validates_uniqueness_of :name, :scope => :user_id, 
      :message => "for this user is already taken! (Cant have duplicate Projects)"
    belongs_to :user
    has_many :todos
    
    def to_s
      name
    end
    
    def self.provision_for_user(user)
      ver = '0.2'
      Project.create([
        { :name => 'personal' , :description => "AutoProvisioned Projects v.#{ver}", :color => :orange, :user_id => user.id },
        { :name => 'work'     , :description => "AutoProvisioned Projects v.#{ver}", :color => :green,  :user_id => user.id }, 
        { :name => 'septober' , :description => "AutoProvisioned Projects v.#{ver}", :color => :gray,   :user_id => user.id },
        { :name => 'family'   , :description => "AutoProvisioned Projects v.#{ver}", :color => :purple, :user_id => user.id },
        { :name => 'love'     , :description => "AutoProvisioned Projects v.#{ver}", :color => :pink,   :user_id => user.id },
      ])
      
    end
end
