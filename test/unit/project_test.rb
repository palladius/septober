require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  def setup
   # @user = User.first
  end

  def test_validate_all_fixtures
    Project.assert_all_valid()
    #Project.all.each do |p| 
    #  assert p.valid? , "Project ''#{p}'' is not valid: #{p.errorz}"
    #end
  end

  def test_Project_with_name_and_user_should_be_valid
    assert_valid Project.new(:user => User.find_by_username( 'guest' ) , :name => 'test_qwerty' ),  "A test project should be valid (total users = #{User.all})"
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
