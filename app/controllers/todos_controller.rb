class TodosController < ApplicationController
  before_filter :authorize_episode95
  #before_filter :login_required 
  helper :riccardo
  
  def index
    filter_conditions = { :user_id => current_user.id  } 
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
  end

  def create
    params[:todo][:user_id] = current_user.id
    @todo = Todo.new(params[:todo])
    if @todo.save
      flash[:notice] = "Successfully created todo '#{@todo.to_s}'"
      redirect_to todos_url
    else
      render :action => 'new'
    end
  end

  def edit
    @todo = Todo.find_securely(current_user,params[:id])
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
  def set_priority
    _update_field(:priority,params[:new_priority])
  end
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
      flash[:notice] = "Successfully set '#{field_name}'='#{new_val}' for Todo ##{params[:id]}: '#{@todo}'"
      redirect_to todos_url
    else
      render :action => 'edit'
    end
  end
  
  def authorize_episode95
   # user = User.authenticate(params[:login], params[:password])
   # if user
   #   session[:user_id] = user.id
   #   flash[:notice] = "Logged in successfully."
      
    user = authenticate_or_request_with_http_basic do |username, password|
      #username == "guest" && password == "guest"
      User.authenticate(username, password)
    end
    puts "\n\nDEB(authorize_episode95): user='#{user}'\n\n"
    if user
      session[:user_id] = user.id 
    end
    return user || login_required # passing to Ryan Bates thing..
  end
  
=begin
  #  to DRY the methods for TODOS index and TODO show..
  protocol: :xml or :json
  
  Possible options:  
  - :only=>['id','title'] (either on master model or submodels) to restrict explicitally
  - :include for DB relationships
  - :methods for custom model methods
  - for all the rest, there is mastercard. ehm, no, there is explicit XML builder in the view... or here :)

   Resources:
   - http://stackoverflow.com/questions/4363870/rails-json-rendering-ambiguous-table-column-names
   
=end
  def render_todos_xml_or_json(protocol, object_s) # object(s)
    render protocol => object_s, 
      :include => {
        :project=> {:only => [:name, :color ] } 
      }, 
      :methods => [:due_explaination] 
  end
  
end #/TodosController
