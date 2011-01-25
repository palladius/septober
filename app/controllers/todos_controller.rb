class TodosController < ApplicationController
  before_filter :login_required 
  
  def index
    #  Project.with_scope(
    #    :find => {:conditions => "user_id = #{user.id}"},
    #    :create => {:user_id => user.id}
    #  )
    filter_conditions = { :user_id => current_user.id }
    filter_conditions[:project_id] = Project.find_by_name(params[:add_project]).id if params[:add_project]
    
    # TODO joins condition so to MUTE all projects that are UNACTIVE
    
    #filter_conditions[:project_id] = Project.find_by_name(params[:add_project] rescue nil )        # TODO_IMP Try this!!!
    #filter_conditions[:project_id] = Project.find_all_by_name(params.fetch(:add_project, nil) ) # if params[:add_project]
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
  
  def toggle; _update_active(:toggled) ; end 
  def done;   _update_active(:deactivated,false) ; end
  def undone; _update_active(:reactivated,true) ; end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
    flash[:notice] = "Successfully destroyed todo."
    redirect_to todos_url
  end
  
private
  def _update_active(participle,new_active=nil)
    # nil = toggle
    new_active ||= false # should be the REVERSE... TODO!
    # copy the data from edit
    @todo = Todo.find(params[:id])
    if @todo.update_attributes( :active => new_active )
      flash[:notice] = "Successfully '#{participle}' todo ##{params[:id]}"
      redirect_to todos_url
    else
      render :action => 'edit'
    end
  end
end
