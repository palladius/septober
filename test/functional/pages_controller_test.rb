require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get healthz" do
    get :healthz
    assert_response :success
    assert_equal "ok", @response.body
  end

  test "should get statusz" do
    get :statusz
    assert_response :success
  end

  test "should get varz" do
    get :varz
    assert_response :success
  end
end
