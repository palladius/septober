class Todo < ApplicationRecord
  include ActsAsCarlesso
  
  belongs_to :user
  belongs_to :project
  belongs_to :todo, class_name: "Todo", foreign_key: :depends_on_id, optional: true

  acts_as_carlesso
  searchable_by :name, :description

  scope :recent, -> { where('created_at > ?', 1.week.ago) }
  scope :super_recent, -> { where('created_at > ?', 1.day.ago) }
  scope :overdue, -> { where('due < ?', Time.now) }
  scope :active, -> { where(active: true) }
  scope :done, -> { where(active: false) }
  scope :relevant, -> { where(priority: 1..3) }
  scope :owned_by, ->(user) { where(user_id: user.id) }

  validates :name, uniqueness: { scope: :user_id, message: "for this user is already created! (Cant have duplicate Todos)" }
  validates :project, :user, :name, presence: true
  attribute :priority, default: 3
  validates :priority, inclusion: { in: 1..5 }
  validates :progress_status, inclusion: { in: 0..100, message: "is a percentage, please go back to school :P" }, allow_nil: true

  before_create :apply_todo_regex_magic

  acts_as_taggable_on :tags
  acts_as_taggable_on :system_tags

  def to_s
    name.capitalize
  end

  def to_html
    "<span class='todo'>#{self.to_s}</span>"
  end

  def done?
    !active
  end

  def photo_url?
    photo_url.present?
  end

  def self.ids
    all.map(&:id)
  end

  def self.names
    all.map(&:name)
  end

  def progress_status?
    progress_status && progress_status > 0
  end

  def overdue?
    due < Date.today rescue false
  end

  def close_due?
    due < Date.today + 2 rescue false
  end

  def due_explaination
    return 'overdue' if overdue?
    return 'close' if close_due?
    'far'
  rescue
    "DueXplnErr"
  end

  def where?
    self.where.present?
  end

  def still_hidden?
    hide_until && hide_until > Time.now
  end

  def url?
    url.to_s.length > 4
  end

  def self.extract_tags_and_depure(str)
    begin
      words = str.split(/ /)
      tags = words.select{|w| w.match /^@/ }.map{|tag| tag.gsub(/^@/,'')}
      depured_str = words.select{|w| ! w.match /^@/ }.join(' ')
      return [depured_str,tags]
    rescue Exception => e
      puts "\n\tException!! #{e}"
      return [str, [] ]
    end
  end

  def apply_todo_regex_magic
    logger.info "Todo.apply_todo_regex_magic() for ticket ##{self.id rescue :NO_ID}"
    log = []
    begin
      log << "\tDEBUG: apply_todo_regex_magic START for: #{self.inspect}"
      str = self.name || ''
      self.due = Date.today if str.match( / today| oggi/i )
      self.due = Date.tomorrow if str.match( /tomorrow|domani/i )
      self.due = Date.yesterday if str.match( /yesterday| ieri/i )
      self.due ||= Date.today + 7 unless attribute_present?('due')
      
      self.priority = 1 if str.match /^\-\-|\.\.\.$/
      self.priority = 2 if str.match /^\-|\.\.$/
      self.priority = 4 if str.match /^\+|!$/
      self.priority = 5 if str.match /^\+\+|!!$/
      self.description = I18n.t(:quick_created) unless attribute_present?('description')

      if str.match(/ (http(s)?:\/\/\S+)($|\s)/)
        self.url = $1
        log << "URL correctly parsed: '#{$1}'"
        self.name = self.name.gsub($1,' (URL) ')
      end

      depured_str, mytags = Todo.extract_tags_and_depure(str)
      str = depured_str
      mytags.each{|tag|
        self.tag_list.add(tag.to_s)
      }
      self.name = depured_str

      unless attribute_present?('project_id')
        personal = Project.find_by(name: 'personal', user_id: self.user_id)
        if personal
            log << "PersProject: #{personal.inspect}"
            self.project_id = personal.id
        end
      end
      
      self.sys_notes = (self.sys_notes || '') + "\n\n---- LOGS: ----\n#{log.join("\n")}"
      return true
    rescue Exception => e
      logger.error "Todo.apply_todo_regex_magic Exception: #{ e.backtrace.join("\n") }"
      return false
    end
  end

  def self.provision_for_user(user)
    ver = '1.0.3'
    personal = Project.find_by(name: 'personal', user_id: user.id)
    work     = Project.find_by(name: 'work',     user_id: user.id)
    septober = Project.find_by(name: 'septober', user_id: user.id)
    tail = "--\nAutoProvisioned Todos v.#{ver}"
    
    return unless personal && work && septober

    create!([
      {user_id: user.id, project_id: personal.id, name: 'Go shopping' , 
        due: Date.today + 14 ,
        where: "Tesco, Parnell St, Dublin",
        description: "Buy Milk, Coffee, Toilet Paper, tomato, shrimps, peas, cream \n #{tail}" },
      {user_id: user.id, project_id: work.id,     name: 'Organize meeting to your boss by tomorrow!' , 
        priority: 4, 
        due: Date.tomorrow ,
        description: tail  },
      {user_id: user.id, project_id: septober.id,
         name: 'Cleanup the room' , 
         due: Date.today + 365 ,
         hide_until: Time.now + 86400 * 7 ,
         description: "Something to be done in 1yr time, hidden again for the next year!"+tail },
      {user_id: user.id, project_id: personal.id,
         name: 'Buy new shoes by saturday!' , 
         due: Date.today + 30 ,
         where: 'Grafton St, Dublin, Ireland',
         description: "Something to be done in 1yr time"+tail },
      {user_id: user.id, project_id: septober.id,
         name: 'Drink guinness with friends' , 
         photo_url: 'http://adsoftheworld.com/files/images/guinness-april-fool.preview.jpg',
         due: Date.today + 30 ,
         where: 'The Duke, Dublin, Ireland',
         description: "Something to be done in 1yr time"+tail },
      {user_id: user.id, project_id: septober.id, 
        due: Date.yesterday ,
        name: 'Thank Riccardo for this wonderful application' , description: "His email is #{$APP[:author] rescue "Dunno"}" },
    ])
  end
end
