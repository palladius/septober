require 'test_helper'

class TodosControllerTest < ActionController::TestCase
  def setup
    Todo.delete_all
    Project.delete_all
    User.delete_all
    @user = User.create!(username: "test_user", email: "test@example.com", password: "password1", password_confirmation: "password1")
    @project = @user.projects.find_by(name: "personal") || Project.create!(name: "custom_proj", user_id: @user.id)
    @todo = Todo.create!(name: "Initial task", user_id: @user.id, project_id: @project.id, due: Date.today + 2, priority: 3, active: true)
    session[:user_id] = @user.id
  end

  test "index gets todos for user" do
    get :index
    assert_response :success
    assert_select ".todo-item"
  end

  test "done marks todo inactive" do
    get :done, params: { id: @todo.id }
    assert_redirected_to todos_url
    @todo.reload
    assert_equal false, @todo.active
  end

  test "procrastinate extends due date" do
    initial_due = @todo.due
    get :procrastinate, params: { id: @todo.id }
    assert_redirected_to todos_url
    @todo.reload
    assert @todo.due > initial_due
  end

  test "turbo stream done replacement" do
    get :done, params: { id: @todo.id }, as: :turbo_stream
    assert_response :success
    assert_includes @response.media_type, "turbo-stream"
  end
end
