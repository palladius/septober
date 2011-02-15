require 'test_helper'

class TodoTest < ActiveSupport::TestCase


  def setup
    #puts "Todo.setup: Users are: #{green User.all}" 
    #puts "Todo.setup: Project are: #{green Project.all.map{|p| "#{p.name} (by #{p.user})" } }" 
    guest = User.find_by_username 'guest'
    root  = User.find_by_username 'root'
    test  = User.find_by_username 'test'
  end
  
  def todos_fixtures_must_all_be_valid
    Todo.assert_all_valid()
  end

  def test_A_TODO_with_project_belonging_to_user_should_be_valid
    todo = Todo.new( 
      :user => guest,
      :project => guest.projects.first,
      :name => "This is a fake todo from random user and a project he/she DOES own"
    )
    pred "Todo errors: #{todo.errors.inspect}" unless todo.valid?
    assert todo.valid?
  end
  
  def test_A_TODO_with_project_belonging_to_other_user_should_NOT_be_valid
    todo = Todo.new( 
      :user => guest,
      :project => root.projects.first,
      :name => "This is a fake todo from random user and a project he/she DOES own"
    )
    pred "Todo errors: #{todo.errors.inspect}" unless todo.valid?
    assert todo.valid?
  end
  
end
