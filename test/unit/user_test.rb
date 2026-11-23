require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def new_user(attributes = {})
    attributes[:username] ||= 'foo'
    attributes[:email]    ||= 'foo@example.com'
    attributes[:password] ||= 'abc123'
    attributes[:password_confirmation] ||= attributes[:password]
    user = User.new(attributes)
    user.valid? # run validations
    user
  end

  def setup
    User.delete_all
  end

  def users_fixtures_must_all_be_valid
    User.assert_all_valid()
  end
  
  def test_valid
    assert new_user.valid?
  end

  def test_require_username
    assert new_user(:username => '').errors[:username]
  end

  def test_require_password
    assert new_user(:password => '').errors[:password]
  end

  def test_require_well_formed_email
    assert new_user(:email => 'foo@bar@example.com').errors[:email]
  end

  def test_validate_uniqueness_of_email
    new_user(:email => 'bar@example.com').save!
    assert new_user(:email => 'bar@example.com').errors[:email]
  end

  def test_validate_uniqueness_of_username
    new_user(:username => 'uniquename').save!
    assert new_user(:username => 'uniquename').errors[:username]
  end

  def test_validate_odd_characters_in_username
    assert new_user(:username => 'odd ^&(@)').errors[:username]
  end

  def test_validate_password_length
    assert new_user(:password => 'bad').errors[:password]
  end

  def test_require_matching_password_confirmation
    assert new_user(:password_confirmation => 'nonmatching').errors[:password]
  end

  def test_generate_password_hash_and_salt_on_create
    user = new_user
    user.save!
    assert user.password_hash
    assert user.password_salt
  end

  def test_authenticate_by_username
    User.delete_all
    user = new_user(:username => 'foobar', :password => 'secret')
    user.save!
    assert_equal user, User.authenticate('foobar', 'secret')
  end

  def test_authenticate_by_email
    User.delete_all
    user = new_user(:email => 'foo@bar.com', :password => 'secret')
    user.save!
    assert_equal user, User.authenticate('foo@bar.com', 'secret')
  end

  def test_authenticate_bad_username
    assert_nil User.authenticate('nonexisting', 'secret')
  end

  def test_authenticate_bad_password
    User.delete_all
    new_user(:username => 'foobar', :password => 'secret').save!
    assert_nil User.authenticate('foobar', 'badpassword')
  end

  def test_parent_child_agent_hierarchy
    parent = new_user(:username => 'parent_user', :email => 'parent@example.com')
    parent.save!
    assert parent.human?
    assert !parent.agent?

    child = new_user(
      :username => 'child_agent',
      :email => 'agent@example.com',
      :parent_id => parent.id,
      :is_agent => true,
      :agent_host => 'mini-lobby',
      :agent_icon => '🚛'
    )
    child.save!
    assert child.agent?
    assert !child.human?
    assert_equal parent, child.parent
    assert_includes parent.agents, child
    assert_equal [parent.id, child.id].sort, parent.family_user_ids.sort
    assert_equal [child.id], child.family_user_ids
  end

  def test_single_level_depth_restriction
    grandparent = new_user(:username => 'grandpa', :email => 'grandpa@example.com')
    grandparent.save!

    parent = new_user(:username => 'parent_agent', :email => 'p_agent@example.com', :parent_id => grandparent.id, :is_agent => true)
    parent.save!

    # Attempting to attach an agent to an agent should fail validation
    grandchild = new_user(:username => 'grandchild', :email => 'gc@example.com', :parent_id => parent.id, :is_agent => true)
    assert !grandchild.valid?
    assert grandchild.errors[:parent_id].present?
  end
end
