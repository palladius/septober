require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    Todo.delete_all
    Project.delete_all
    User.delete_all
    @user = User.create!(username: "human_user", email: "human@example.com", password: "secret123", password_confirmation: "secret123")
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create_valid
    assert_difference("User.count") do
      post :create, params: { user: { username: "new_human", email: "new_human@example.com", password: "secret123", password_confirmation: "secret123" } }
    end
    assert_redirected_to "/"
  end

  def test_provision_subagent_when_logged_in
    session[:user_id] = @user.id
    assert_difference("@user.agents.count", 1) do
      post :create, params: {
        user: {
          username: "human_user.agent_test",
          email: "agent@example.com",
          password: "agentpass123",
          password_confirmation: "agentpass123",
          parent_id: @user.id,
          is_agent: true,
          agent_icon: "🤖",
          agent_host: "mini-lobby"
        }
      }
    end
    assert_redirected_to edit_user_path(@user)
  end

  def test_edit_when_logged_in
    session[:user_id] = @user.id
    get :edit, params: { id: @user.id }
    assert_response :success
  end
end
