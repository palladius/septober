require 'test_helper'

class Api::TodosControllerTest < ActionController::TestCase
  def setup
    @user = User.first
    @user.update!(password: "secret", password_confirmation: "secret")
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(@user.username, "secret")
  end

  test "index returns json" do
    get :index, format: :json
    assert_response :success
    json = JSON.parse(@response.body)
    assert json.is_a?(Array)
  end

  test "create todo via json" do
    assert_difference("Todo.count") do
      post :create, format: :json, params: { name: "Agent task 1", priority: 4 }
    end
    assert_response :created
    json = JSON.parse(@response.body)
    assert_equal "Agent task 1", json["name"]
  end

  test "toggle todo via json" do
    todo = @user.todos.first
    initial_status = todo.active
    get :toggle, format: :json, params: { id: todo.id }
    assert_response :success
    todo.reload
    assert_equal !initial_status, todo.active
  end
end
