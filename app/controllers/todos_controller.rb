class TodosController < ApplicationController
  before_filter :login_required 
  
  def index
    #  Project.with_scope(
    #    :find => {:conditions => "user_id = #{user.id}"},
    #    :create => {:user_id => user.id}
    #  )
    filter_conditions = { :user_id => current_user.id }
    filter_conditions[:project_id] = Project.find_by_name(params[:add_project]) if params[:add_project]
    @todos = Todo.find(:all, 
      #:conditions => "user_id = #{current_user.id}", 
      :conditions => filter_conditions, 
      :order => 'active DESC, priority DESC, updated_at DESC')
  end

  def show
    @todo = Todo.find(params[:id])
  end

  def new
    @todo = Todo.new
  end

  def create
    params[:todo][:user_id] = current_user.id
    @todo = Todo.new(params[:todo])
    if @todo.save
      flash[:notice] = "Successfully created todo."
      #redirect_to @todo
      redirect_to todos_url
    else
      render :action => 'new'
    end
  end

  def edit
    @todo = Todo.find(params[:id])
  end

  def update
    @todo = Todo.find(params[:id])
    if @todo.update_attributes(params[:todo])
      flash[:notice] = "Successfully updated todo."
      #redirect_to todo_url
      redirect_to todos_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
    flash[:notice] = "Successfully destroyed todo."
    redirect_to todos_url
  end
end
