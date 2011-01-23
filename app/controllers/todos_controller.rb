class TodosController < ApplicationController
  before_filter :login_required 
  
  def index
    #  Project.with_scope(
    #    :find => {:conditions => "user_id = #{user.id}"},
    #    :create => {:user_id => user.id}
    #  )
    @todos = Todo.find(:all, :conditions => "user_id = #{current_user.id}", :order => 'updated_at DESC')
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
      #      redirect_to @todo
      redirect_to :action => 'index'
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
      redirect_to todo_url
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
