class Project < ActiveRecord::Base
    attr_accessible :name, :description, :color, :active, :user_id, :home_visible, :public , :photo_url # system is NOT accessible!!
    
    # only one 'personal' of a name per user..
    validates_format_of :name, :with => /^[a-z_]+$/, :message => "is invalid (only lowercase letters and _)"
    validates_uniqueness_of :name, :scope => :user_id, 
      :message => "for this user is already taken! (Cant have duplicate Projects)"
    belongs_to :user
    has_many :todos
    searchable_by :name, :description
    acts_as_carlesso
    scope :publics,  lambda { { :conditions => ['public = ?', true  ] } }
    scope :public,  lambda { { :conditions => ['public = ?', true  ] } }
    
    acts_as_taggable_on :tags        # normal
    acts_as_taggable_on :magic_tags    

    def to_s
      name
    end
    
    def name_and_activity() # For Todo creation form
      active ? name : "#{name} (unactive!)"
    end
    
    def self.provision_for_user(user)
      ver = '0.2.2 (added)'
      # 0.2.2: added :system => true for these
      # 0.2.1: boh
      tail = "--\nAutoProvisioned Projects v.#{ver}"
      Project.create([
        { :name => 'personal' , :description => "Your personal stuff"+tail,                   :system => true, :color => :orange, :user_id => user.id },
        { :name => 'work'     , :description => "Your work or school stuff"+tail,             :system => true, :color => :green,  :user_id => user.id },
        { :name => 'septober' , :description => "Personal (family, love, hobbies, ...)"+tail, :system => true, :color => :gray,   :user_id => user.id },
      #  { :name => 'family'   , :description => "AutoProvisioned Projects v.#{ver}", :color => :purple, :user_id => user.id },
      #  { :name => 'love'     , :description => "AutoProvisioned Projects v.#{ver}", :color => :pink,   :user_id => user.id },
      ])
    end
    
    def self.default(user)
      projects = user.projects
      # return 'inbox'    if you find it.
      # return 'personal' if you find it.
      # return exception
    end

end
