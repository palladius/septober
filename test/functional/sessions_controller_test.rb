require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def test_new
    get :new
    assert_response :success
  end

  def test_create_invalid
    post :create, params: { login: "nonexistent", password: "wrong" }
    assert_response :unprocessable_entity
    assert_nil session['user_id']
  end

  def test_create_valid
    user = User.first
    user.update!(password: "secret", password_confirmation: "secret")
    post :create, params: { login: user.username, password: "secret", remember_me: "1" }
    assert_redirected_to "/"
    assert_equal user.id, session['user_id']
    assert_equal user.id, cookies.permanent.signed['user_id']
  end

  def test_destroy
    session['user_id'] = User.first.id
    delete :destroy
    assert_redirected_to "/"
    assert_nil session['user_id']
    assert_nil cookies['user_id']
  end
end
