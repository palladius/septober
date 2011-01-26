class Todo < ActiveRecord::Base
    attr_accessible :name, :description, :active, :due, :user_id, :where, :priority, :project_id
      
    belongs_to :user
    belongs_to :project
    
    scope :recent, lambda { { :conditions => ['created_at > ?', 1.week.ago] } }
    scope :super_recent, lambda { { :conditions => ['created_at > ?', 1.day.ago] } }
    scope :overdue,  lambda { { :conditions => ['due > ?', Time.now ] } }
    # More here: http://railscasts.com/episodes/15-fun-with-find-conditions
    # Task.find_all_by_priority(1..3)
    scope :relevant, lambda { { :conditions => ['priority in ?', 1..3 ] } }
    
    validates_uniqueness_of :name, :scope => :user_id, :message => "for this user is already created! (Cant have duplicate Todos)"
    validates_associated :project, :user
    validates_presence_of :project, :user, :name
    validates_inclusion_of :priority, :in => 1..5 ## , :message => "number must be in 1..5!"

    def to_s
      name
    end
    
    # TODO put a link of interesting queries top left
    def self.interesting_queries
      [:recent, :super_recent, :overdue, :relevant ]
    end
    
    def to_html
      'TODO_HTML'
    end
    
    def done?
      ! active
    end
    
    def self.ids
      find(:all).map{|t| t.id}
    end
    def self.names
      find(:all).map{|t| t.name}
    end
    
    # autodeducts the projects, and other... :)
    def self.magic_create(str)
      # autodetect stuff!
    end
    
    def overdue?
      due < Date.today rescue false
    end
    
    def self.provision_for_user(user)
      ver = '0.1.0'
      projects = {}
      #Todo.with_scope(:find => {:conditions => "user_id = #{current_user.id}"},
      #                :create => {:user_id => current_user.id}) do
      # user_posts = Post.find(:all)
      #Project.with_scope(
      #  :find => {:conditions => "user_id = #{user.id}"},
      #  :create => {:user_id => user.id}
      #) do
      #  %w{ personal work septober }.each { |pname| 
      #    projects[pname.to_sym] = Project.find_by_name(pname)
      #  }
      #end
      personal = Project.find_by_name_and_user_id('personal',user.id)
      work     = Project.find_by_name_and_user_id('work',    user.id)
      septober = Project.find_by_name_and_user_id('septober',user.id)
      tail = "--\nAutoProvisioned Todos v.#{ver}"
      Todo.create([
        {:user_id => user.id, :project_id => personal.id, :name => 'Buy milk and condoms' , :description => tail, :where => Socket.gethostname },
        {:user_id => user.id, :project_id => work.id,     :name => 'Organize meeting to your boss' , :description => tail  },
        {:user_id => user.id, :project_id => septober.id, :name => 'Eventually cleanup the room' , :description => "Something to be done in 1yr time"+tail },
        {:user_id => user.id, :project_id => septober.id, :name => 'Thank Riccardo for this wonderful application' , :description => "His email is "+ $APP[:email] },
      ])
    end
end
