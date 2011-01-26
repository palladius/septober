require 'test_helper'

class TodosControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Todo.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Todo.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Todo.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to todo_url(assigns(:todo))
  end

  def test_edit
    get :edit, :id => Todo.first
    assert_template 'edit'
  end

  def test_update_invalid
    Todo.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Todo.first
    assert_template 'edit'
  end

  def test_update_valid
    Todo.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Todo.first
    assert_redirected_to todo_url(assigns(:todo))
  end

  def test_destroy
    todo = Todo.first
    delete :destroy, :id => todo
    assert_redirected_to todos_url
    assert !Todo.exists?(todo.id)
  end
  
  def test_cannot_see_someone_elses_todo
    puts "Serena asked me to do this.."
    assert false
  end
end
