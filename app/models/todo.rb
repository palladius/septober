class Todo < ActiveRecord::Base
    @@default_procrastination = 7
  
    require 'socket'
  
    attr_accessible :name, :description, :active, :due, :user_id, :where, :priority, :project_id, :url,
      :progress_status, :favorite, :hide_until, :depends_on_id, :source, :photo_url
    searchable_by :name, :description # , :where forbidden until u fix the search!
    acts_as_carlesso
    
    belongs_to :user
    belongs_to :project
    belongs_to :todo, :class_name => "Todo", :foreign_key => :depends_on_id
    
    scope :recent, lambda { { :conditions => ['created_at > ?', 1.week.ago] } }
    scope :super_recent, lambda { { :conditions => ['created_at > ?', 1.day.ago] } }
    scope :overdue,  lambda { { :conditions => ['due > ?', Time.now ] } }
    scope :active,  lambda { { :conditions => ['active = ?', true  ] } }
    scope :done,    lambda { { :conditions => ['active = ?', false ] } }
    # More here: http://railscasts.com/episodes/15-fun-with-find-conditions
    # Task.find_all_by_priority(1..3)
    scope :relevant, lambda { { :conditions => ['priority in ?', 1..3 ] } }
    #scope :automine, lambda { { :conditions => ['user_id = ?', current_user.id  ] } }
    scope :owned_by, lambda {|user| { :conditions => ['user_id = ?', user.id] } }
    
    validates_uniqueness_of :name, :scope => :user_id, :message => "for this user is already created! (Cant have duplicate Todos)"
    validates_associated :project, :user
    validates_presence_of :project, :user, :name
    validates_inclusion_of :priority, :in => 1..5 ## , :message => "number must be in 1..5!"
    validates_inclusion_of :progress_status, :in => 0..100, :message => "is a percentage, please go back to school :P"
    
    #  before_save :apply_todo_regex_magic #    RIGHT NOW... TO BECOME => BeforeCreate
    before_create :apply_todo_regex_magic
    #after_create :apply_todo_regex_magic
    
    # TODO
    acts_as_taggable_on :tags        # normal, user created
    acts_as_taggable_on :system_tags # system created

    def to_s
      name.capitalize
    end
    
    # TODO put a link of interesting queries top left
    def self.interesting_queries
      [:recent, :super_recent, :overdue, :relevant ]
    end
    
    def to_html
      "<span class='todo'>#{self.to_s}</span>"
      #TodosHelper::render_todo_name(self)
    end
    
    def done?
      ! active
    end
    
    def photo_url?
      photo_url.to_s != '' rescue true
    end
    
    def self.ids
      find(:all).map{|t| t.id}
    end
    def self.names
      find(:all).map{|t| t.name}
    end
    
    # autodeducts the projects, and other... :)
    #def self.magic_create(str)
    #  # autodetect stuff!
    #end
    
    def progress_status?
      progress_status && progress_status > 0 rescue false
    end
    
    def overdue?
      #due < Date.today && active == true rescue false
      due < Date.today rescue false
    end
    
    def close_due?
      due < Date.today + 2 rescue false
    end
    
    # overdue, close, far
    def due_explaination
      overdue? ? 'overdue' : (
        close_due? ? 'close' : 'far'
      )  rescue "DueXplnErr(#{$!})"# i.e. close = within 2 days
    end
    
    # has location
    def where?
      self.where.to_s.length > 0
    end
    
    def still_hidden?
      hide_until && hide_until > Time.now
    end
    
    def url?
      url.to_s.length > 4 # spannometrically
    end
    
  # This should do some magic stuff like adding the due to tomorrow if string matches 'by tomorrow' or 'entro domani' and so on..  
		# TODO FACILE: substitute the logs from description to sys_notes
    def apply_todo_regex_magic
      log = []
      begin # catch exceptions
        log << "\tDEBUG: apply_todo_regex_magic START for: #{self.inspect}"
        str = self.name rescue ''
        @due = Date.today if str.match /today| oggi/i
        self.due = Date.tomorrow if str.match /tomorrow|domani/i # TODO \<string\>
        self.due = Date.yesterday if str.match /yesterday| ieri/i 
        @due ||= Date.today + 7 unless attribute_present?('due') # in 7 days
        # TODO and priority = 3
        self.priority = 1 if str.match /^\-\-|\.\.\.$/ # TODO remove the ++
        self.priority = 2 if str.match /^\-|\.\.$/ # TODO remove the ++
        self.priority = 4 if str.match /^\+|!$/ # TODO remove the ++
        self.priority = 5 if str.match /^\+\+|!!$/ # TODO remove the ++
        self.description = I18n.t(:quick_created) unless attribute_present?('description') # alredy created
      
        # Autopopulate the URL:
        if str.match(/ (http(s)?:\/\/\S+)($|\s)/) # URL in the middle between spaces OR 
          self.url = $1  # http:/... separated with spaces
          log << "URL correctly parsed: '#{$1}'"
          self.name = self.name.gsub($1,' (URL) ')
        end
        # doiesnt work properly yet
        #if str.match /(@|at) (\S+)/  # "@ Vatican" or "at vatican" Note that if two spaces only the first is taken (TODO maybe until $ ?)
        #  regexed_place = $3
        #  self.where = regexed_place
        #  log << "A place has been found: #{regexed_place}"
        #end
        # PROJECT: This should be done in the regex magic!!!
        # TODO if the first word matches an existing project, do it!
        unless attribute_present?('project_id')
          personal = Project.find_by_name_and_user_id('personal',self.user_id)
          log << "PersProject: #{personal.inspect}"
          self.project_id = personal.id #Project.find_by_name_and_user_id('personal',self.user_id).id
        end
        #self.url  = 'test url3' # this works
        @where = 'Inferred from Current IP TODO :)'
        # if i dont find a project, set project to personal
        #raise 'cant call apply_todo_regex_magic without knowing WHO i am (current_user is not available in model dear Ric)' unless self.user_id
        where = 'boh'
        #raise 'test exception'
        #self.save rescue 'err'
        puts log
        self.sys_notes = (self.sys_notes || '') + "\n\n---- LOGS: ----\n#{log.join("\n")}"
        return true
      rescue Exception => e
        pred "Todo.apply_todo_regex_magic Exception: #{$!}"
        return false
      end
    end
    
    def self.public_apply_todo_regex_magic(todo)
      todo.description = 'public test'
      todo.priority = 5
    end
    
    def self.provision_for_user(user)
      ver = '1.0.2' # it works!
      # 1.0.1 was broken because i removed :eamil field!
      projects = {}
      personal = Project.find_by_name_and_user_id('personal',user.id)
      work     = Project.find_by_name_and_user_id('work',    user.id)
      septober = Project.find_by_name_and_user_id('septober',user.id)
      tail = "--\nAutoProvisioned Todos v.#{ver}"
      Todo.create([
        {:user_id => user.id, :project_id => personal.id, :name => 'Go shopping' , 
          :due => Date.today + 14 ,
          :where => "Tesco, Parnell St, Dublin",
          :description => "Buy Milk, Coffee, Toilet Paper, tomato, shrimps, peas, cream \n #{tail}", :where => "Host: #{Socket.gethostname rescue 'Boh'}" },
        {:user_id => user.id, :project_id => work.id,     :name => 'Organize meeting to your boss by tomorrow!' , 
          :priority => 4, 
          :due => Date.tomorrow , # TODO may have to make it with a lambda # like:  lambda { Date.tomorrow }
          :description => tail  },
        {:user_id => user.id, :project_id => septober.id,
           :name => 'Cleanup the room' , 
           :due => Date.today + 365 , # next week
           :hide_until => Time.now + 86400 * 7 ,
           :description => "Something to be done in 1yr time, hidden again for the next year!"+tail },
        {:user_id => user.id, :project_id => personal.id,
              :name => 'Buy new shoes by saturday!' , 
              :due => Date.today + 30 , # next week
              :where => 'Grafton St, Dublin, Ireland',
              :description => "Something to be done in 1yr time"+tail },
        {:user_id => user.id, :project_id => septober.id,
              :name => 'Drink guinness with friends' , 
              :due  => Date.today + 30 , # next week
              :where => 'The Duke, Dublin, Ireland',
              :description => "Something to be done in 1yr time"+tail },
        {:user_id => user.id, :project_id => septober.id, 
          :due => Date.yesterday ,
          :name => 'Thank Riccardo for this wonderful application' , :description => "His email is #{$APP[:author] rescue "Dunno"}" },
      ])
    end
    
    def search_tbd(q)
    end
    
    def self.find_securely(user,whatever,opts={})
      Todo.with_scope(
        :find =>   { :conditions => "user_id = #{user.id}"},
        :create => { :user_id => user.id }
      ) do
        find(whatever,opts)
      end
    end
end
