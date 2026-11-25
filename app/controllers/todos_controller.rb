# encoding: utf-8
class TodosController < ApplicationController
  before_filter :login_required 
  helper :riccardo
  
  can_edit_on_the_spot
  
  def index
    allowed_ids = current_user.respond_to?(:family_user_ids) ? current_user.family_user_ids : [current_user.id]
    if params[:agent_id].present?
      target_id = params[:agent_id].to_i
      query_ids = allowed_ids.include?(target_id) ? [target_id] : []
    else
      query_ids = allowed_ids
    end
    filter_conditions = { :user_id => query_ids } 
    #  Project: , :home_visible => true
    filter_conditions[:project_id] = Project.find_by_name_and_user_id(params[:add_project], current_user.id).id if params[:add_project]
    filter_conditions[:projects] = { :home_visible => true } unless params[:add_project] # in which case i show everything
    @todos = Todo.find :all, 
      :joins => :project,
      :conditions => filter_conditions, 
      :order => 'active DESC, priority DESC, updated_at DESC',
      :limit => 20
    respond_to do |format|
      format.html 
      format.xml  { render_todos_xml_or_json :xml,  @todos } # :due_explaination
      format.json { render_todos_xml_or_json :json, @todos }
    end
  end
  
  def set_todo_where
    raise params.inspect
  end

  def show
    @todo = Todo.find_securely(current_user,params[:id]) rescue nil
    respond_to do |format|
      format.html 
      #format.xml  { render :xml  => @todo, $XML_TODO_OPTS } # :include => [:project] , :methods => [:due_explaination] }
      format.xml  { render_todos_xml_or_json :xml ,  @todo }
      format.json { render_todos_xml_or_json :json , @todo }
    end
  end

  def new
    @todo = Todo.new
    # 2019-05-12 TEST
    #@todo.system_tags = [ "api_call" ]
    #@todo.tags = []
  end

  def create
    params[:todo][:user_id] = current_user.id
    #params[:todo][:tags] ||= []
    @todo = Todo.new(params[:todo])
    if @todo.save
      flash[:notice] = "Successfully created todo ##{@todo.id} '#{@todo.to_s}'"
      redirect_to todos_url
    else
      render :action => 'new'
    end
  end

  def edit
    @todo = Todo.find_securely(current_user,params[:id])
  end

  def update
    @todo = Todo.find_securely(current_user, params[:id])
    todo_attrs = params[:todo] || {}
    saved = @todo.update_attributes(todo_attrs)

    # Fallback for vintage todos whose legacy name/project might fail unrelated validations
    # when only inline-updating progress_status or priority within valid bounds.
    if !saved && todo_attrs.any? && (todo_attrs.keys.map(&:to_s) - ['progress_status', 'priority']).empty?
      direct_updates = {}
      bounds_ok = true
      if todo_attrs.key?(:progress_status) || todo_attrs.key?('progress_status')
        pv = (todo_attrs[:progress_status] || todo_attrs['progress_status']).to_i
        bounds_ok = false unless (0..100).include?(pv)
        direct_updates[:progress_status] = pv
      end
      if todo_attrs.key?(:priority) || todo_attrs.key?('priority')
        prv = (todo_attrs[:priority] || todo_attrs['priority']).to_i
        bounds_ok = false unless (1..5).include?(prv)
        direct_updates[:priority] = prv
      end
      if bounds_ok && direct_updates.any?
        direct_updates[:updated_at] = Time.now
        Todo.update_all(direct_updates, { :id => @todo.id })
        @todo.reload
        saved = true
      end
    end

    if saved
      if request.xhr? || request.format.json?
        render :json => {
          :ok => true,
          :id => @todo.id,
          :priority => @todo.priority,
          :google_priority => (5 - @todo.priority.to_i),
          :progress_status => @todo.progress_status
        }
      else
        flash[:notice] = "Successfully updated todo ##{@todo.id}"
        redirect_to todos_url
      end
    else
      if request.xhr? || request.format.json?
        render :json => { :ok => false, :errors => @todo.errors.full_messages }, :status => 422
      else
        render :action => 'edit'
      end
    end
  end
  
  def toggle; _update_active(:toggled) ; end 
  def done;   _update_active(:deactivated,false) ; end
  def undone; _update_active(:reactivated,true) ; end
  def set_priority
    _update_field(:priority,params[:new_priority])
  end
  
  def procrastinate
    # procrastinate by 7
    n_days = params.fetch( :procrastinate_days, 7 )
    _update_field(:due,Date.today + n_days )
  end
  
  # sleep = hide_until
  def sleep
    # hide_untile by Time.now + 8.days
    n_days = params.fetch( :hide_until_days, 8 )
    _update_field(:hide_until, Time.now + n_days.to_i.days )
  end
  
# Project.destroy which works to get inspired...
  # def destroy
  #   pred "I have a feeling the same bug also affects projects. Lets see if this line is ever reached when I click destroy. No its not then its JS"
  #   @project = Project.find(params[:id])
  #   @project.destroy
  #   flash[:notice] = "Successfully destroyed project."
  #   redirect_to projects_url
  # end

  def destroy
    #broken so lets debug
    pyellow "TODO::Destroy. Params: #{params}"
    @todo = Todo.find(params[:id])
    @todo.destroy
    flash[:notice] = "Successfully destroyed todo ##{@todo.id}."
    redirect_to todos_url
  end
  
private
  def _update_active(participle,new_active=nil)
    # nil = toggle
    pgreen '_update_active(participle=#{participle})...'
    new_active ||= false # should be the REVERSE... TODO!
    # copy the data from edit
    #@todo = Todo.find(params[:id])
    @todo = Todo.find_securely(current_user, params[:id])
    if @todo.update_attributes( :active => new_active )
      flash[:notice] = "Successfully '#{participle}' todo ##{params[:id]}"
      redirect_to todos_url
    else
      render :action => 'edit'
    end
  end
  
  def _update_field(field_name,new_val)
    @todo = Todo.find_securely(current_user,params[:id])
    if @todo.update_attributes( field_name.to_sym => new_val )
      if request.xhr? || request.format.json?
        render :json => { :ok => true, :id => @todo.id, field_name.to_sym => @todo.send(field_name) }
      else
        flash[:notice] = "Successfully set '#{field_name}'='#{new_val}' for Todo ##{params[:id]}"
        redirect_to todos_url
      end
    else
      if request.xhr? || request.format.json?
        render :json => { :ok => false, :errors => @todo.errors.full_messages }, :status => 422
      else
        render :action => 'edit'
      end
    end
  end
  

end #/TodosController
