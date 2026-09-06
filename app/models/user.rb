require 'bcrypt'

class User < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :todos, dependent: :destroy

  # Parent-child agent hierarchy
  belongs_to :parent, class_name: "User", foreign_key: :parent_id, optional: true
  has_many :agents, class_name: "User", foreign_key: :parent_id, dependent: :destroy

  validates :username, presence: true, uniqueness: { allow_blank: true }, format: { with: /\A[-\w\._@]+\z/i, message: "should only contain letters, numbers, or .-_@" }
  validates :email, format: { with: /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i }
  validates :password, length: { minimum: 4, allow_blank: true }, on: :create
  validates :password, confirmation: true
  validate :validate_single_level_depth

  def validate_single_level_depth
    if parent_id.present?
      parent_user = User.find_by(id: parent_id)
      if parent_user && parent_user.parent_id.present?
        errors.add(:parent_id, "cannot have a parent that is already a child agent (max depth is 1)")
      end
      if is_agent? && agents.any?
        errors.add(:base, "an agent cannot have child agents")
      end
    end
  end

  def agent?
    is_agent == true
  end

  def human?
    !agent?
  end

  def resolved_agent_icon
    val = read_attribute(:agent_icon)
    return val if val.present? && val != '?'
    slug = username.to_s.split('.').last.downcase
    case slug
    when 'ermete' then '🚛'
    when 'lobby'  then '🦞'
    when 'pux'    then '🐾'
    else '🤖'
    end
  end

  def family_user_ids
    if agent?
      [self.id]
    else
      [self.id] + agents.map(&:id)
    end
  end

  attr_accessor :password

  before_save :prepare_password
  after_create :provision_projects_after_create

  def to_s
    username
  end

  def name
    username
  end

  def provision_projects_after_create
    return if agent?
    puts "+ Creating projects for new user '#{self}'.."
    Project.provision_for_user(self)
    puts "+ Creating todos for new user '#{self}'.."
    Todo.provision_for_user(self)
  end

  def self.authenticate(login, pass)
    user = find_by(username: login) || find_by(email: login)
    return user if user && user.matching_password?(pass)
  end

  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = BCrypt::Engine.generate_salt.to_s.force_encoding("UTF-8")
      self.password_hash = encrypt_password(password).to_s.force_encoding("UTF-8")
    end
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end
end
