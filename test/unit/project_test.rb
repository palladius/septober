require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  

  def setup
   $guest = User.find_by_username 'guest' 
  end

  def test_validate_all_project_fixtures
    Project.assert_all_valid(self)
    #Project.all.each do |p| 
    #  assert p.valid? , "Project ''#{p}'' is not valid: #{p.errorz}"
    #end
  end
  
  def test_guest_is_ok
    pyellow "Guest user: #{$guest.inspect}"
    assert_equal($guest.name, 'guest', "This should be a guest user")
    assert_valid($guest)
  end

  def test_Project_with_name_and_user_should_be_valid

    proj = Project.new(
      :user_id =>  $guest.id , 
      :name => 'test_qwerty' )
    assert_valid proj,  "A test project '#{proj} by #{proj.user}' should be valid (total users = #{User.all})"
  end
  
  def test_some_invalid_names
    [ 'ThisHasUppercase' , 'This has spaces' , 'this_has_s%mbols' ].each do |pname| 
      assert ! Project.new(:user => @user , :name => pname ).valid?, "Project called '#{pname}' should NOT be valid"
    end
  end
  
  def test_Project_with_name_and_no_user_should_not_be_valid
    assert ! Project.new( :name => 'testtwo' ).valid?
  end
  
end
