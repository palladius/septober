require 'bcrypt'

class User < ActiveRecord::Base
  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email, :password, :password_confirmation
  
# 2020 https://stackoverflow.com/questions/6163759/cant-mass-assign-protected-attributes
  attr_accessible :todos_attributes, :projects_attributes

  attr_accessor :password
  before_save :prepare_password
  after_create :provision_projects_after_create
  
  has_many :projects # , :class_name => "object", :foreign_key => "reference_id"
  has_many :todos # , :class_name => "object", :foreign_key => "reference_id"
  
  validates_presence_of :username
  validates_uniqueness_of :username, :email, :allow_blank => true
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i
  validates_presence_of :password, :on => :create
  validates_confirmation_of :password
  validates_length_of :password, :minimum => 4, :allow_blank => true
  
  def to_s
    username
  end
  #alias :username :name
  def name
    username
  end
  
  # to be called after create!
  def provision_projects_after_create()
    puts "+ Creating projects for new user '#{self}'.."
    Project.provision_for_user(self) # create normal projects for user.
    puts "+ Creating projects for new user '#{self}'.."
    Todo.provision_for_user(self) # create normal projects for user.
  end
  
  # login can be either username or email address
  def self.authenticate(login, pass)
    user = find_by_username(login) || find_by_email(login)
    return user if user && user.matching_password?(pass)
  end

  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end
end
