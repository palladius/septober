class Project < ApplicationRecord
  include ActsAsCarlesso

  belongs_to :user
  has_many :todos, dependent: :destroy

  acts_as_carlesso
  searchable_by :name

  validates :name, format: { with: /\A[a-z0-9_]+\z/, message: "is invalid (only lowercase letters and _ and digits)" }
  validates :name, uniqueness: { scope: :user_id, message: "for this user is already taken! (Cant have duplicate Projects)" }
  validates :user, presence: true

  scope :publics, -> { where(public: true) }
  scope :made_by, ->(user) { where(user_id: user.id) }
  scope :owned_by, ->(user) { where(user_id: user.id) }

  acts_as_taggable_on :tags
  acts_as_taggable_on :magic_tags

  def to_s
    name
  end

  def name_and_activity
    active ? name : "#{name} (unactive!)"
  end

  def self.provision_for_user(user)
    ver = '0.2.2 (added)'
    tail = "--\nAutoProvisioned Projects v.#{ver}"
    create!([
      { name: 'personal', description: "Your personal stuff"+tail, system: true, color: 'orange', user_id: user.id },
      { name: 'work', description: "Your work or school stuff"+tail, system: true, color: 'green', user_id: user.id },
      { name: 'septober', description: "Personal (family, love, hobbies, ...)"+tail, system: true, color: 'gray', user_id: user.id },
    ])
  end
end
