require 'bcrypt'

class User < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :todos, dependent: :destroy

  validates :username, presence: true, uniqueness: { allow_blank: true }, format: { with: /\A[-\w\._@]+\z/i, message: "should only contain letters, numbers, or .-_@" }
  validates :email, format: { with: /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i }
  validates :password, length: { minimum: 4, allow_blank: true }, on: :create
  validates :password, confirmation: true

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
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = encrypt_password(password)
    end
  end

  def encrypt_password(pass)
    BCrypt::Engine.hash_secret(pass, password_salt)
  end
end
