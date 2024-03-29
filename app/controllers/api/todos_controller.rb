class Api::TodosController < ApplicationController
  before_filter :authorize_episode95
  #helper :riccardo
  
  def index
    filter_conditions = { :user_id => current_api_user.id  } 
    #  Project: , :home_visible => true
    filter_conditions[:project_id] = Project.find_by_name_and_user_id(params[:add_project], current_api_user.id).id if params[:add_project]
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
    @todo = Todo.find_securely(current_api_user,params[:id]) rescue nil
    respond_to do |format|
      format.html 
      format.xml  { render_todos_xml_or_json :xml,   @todo } # :include => [:project] , :methods => [:due_explaination] }
      format.json { render_todos_xml_or_json :json , @todo }
    end
  end

  def new
    puts("\n\nNEW params vale: #{params}\n\n")
    pgray "[RiccDEBUGNEW] API::TodoController.create() - param[:todo]=#{params[:todo]}"
    @todo = Todo.new(params[:todo])
    puts("BUG This seems to be broken :/")
    pred("Big Bug dig dug drank drunk")
    # errore credo sia questo: WARNING: Can't mass-assign protected attributes: action, controller, format
    # foprse manca params nel costruittore? forse manca post_params?
  end

  def create
    #pgreen "DEBUG API::TodoController.create()"
    # 20190512 For some reasons, params comes virgin, wihtout [:todo] so I need to push one level.
    params[:todo] = params
    pgray "[RiccDEBUG] API::TodoController.create() - param[:todo]=#{params[:todo]}"

    params[:todo][:user_id] = current_api_user.id
    @todo = Todo.new(params[:todo]) # both HTML and XML :)
    @todo.user_id = current_api_user.id
    @todo.apply_todo_regex_magic() rescue pred("Couldnt apply regex for TODO: #{ @todo }. Error: ''#{ $! }''")
    ret = @todo.save
    respond_to do |format|
      format.xml { 
        if ret
          pred "[RiccDEBUG XML] API::TodoController.create() - ALL GOOD WITH CREATION: param[:todo]=#{params[:todo]}"
          render(:xml => @todo.to_xml, :status => "201 Created yay", :message => "Yay API TOdo created id=TODO") 
        else
          pred "[RiccDEBUG XML] API::TodoController.create() - SOMETHING WRONG WITH CREATION: param[:todo]=#{params[:todo]}"
          render(:xml => @todo.to_xml , :status => :unprocessable_entity, :message => "ERROR API TOdo NOT created id=TODO")
        end
      }
      format.json  { 
        if ret
          pred "[RiccDEBUG JSON] API::TodoController.create() - ALL GOOD WITH CREATION: param[:todo]=#{params[:todo]}"
          render(:json => @todo.to_json, :status => "201 Created yay", :message => "Yay API TOdo created id=TODO") 
        else
          pred "[RiccDEBUG JSON] API::TodoController.create() - SOMETHING WRONG WITH CREATION: param[:todo]=#{params[:todo]}. ret=#{ret}. Errors: #{ @todo.errors}"
          render(:json => @todo.to_json, 
            #:status => "572 JSON Couldnt save it sorry", 
            :status => :unprocessable_entity,
            :message => "ERROR API TOdo NOT created id=TODO. Forse duplicato", 
            :error => "TODO Ho fallito perche: #{ @todo.errors.full_messages }",
            :errors => "TODO Ho fallito perche: #{ @todo.errors.full_messages }",
            #:code => "code",
          )
        end
      }
      format.js # do nothing
    end #/respond_to
    ret_enforced = @todo.save
    pgray( "[RiccDEBUG] API::TodoController.create() - ret[todo save]=#{ret_enforced}")
    return ret_enforced
  end #/create

  def edit
    @todo = Todo.find_securely(current_api_user,params[:id])
  end
  
  def rss
    #@todos = Todo.find(:all, :order => "id DESC", :limit => 20)
    @user  = current_api_user
    @todos = Todo.active.find_securely(current_api_user, :all, :order => "id DESC", :limit => 20)
    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end

  def update
    pyellow "DEBUG API::TodoController.update()"
    # params[:todo][:user_id] = current_api_user.id
    #raise "why should u call update from API? TODO"
    @todo = Todo.find(params[:id])
    @todo.user_id = current_api_user.id
    @todo.apply_todo_regex_magic()
    
    respond_to do |format|
      format.xml { 
        if @todo.save
          render(:xml => @todo.to_xml,  :status => "201 Created yay") 
        else
          render(:xml => @todo.to_xml , :status => "568 Couldnt save it sorry", :message => "XML Update Err: TODO")
        end
      }
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
    #redirect_to todos_url
  end
  def edit
    #@todo = Todo.find(params[:id])
    # 2020 not sure if this works
    update
  end
  def delete
    _update_active("delete")
  end
  
private
  def project_find_for_cli(params={})
    Project.find_by_name('personal') || Project.first
  end
  def _update_active(participle,new_active=nil)
    # nil = toggle
    new_active ||= false # should be the REVERSE... TODO!
    # copy the data from edit
    #@todo = Todo.find(params[:id])
    @todo = Todo.find_securely(current_api_user, params[:id])
    if @todo.update_attributes( :active => new_active )
      flash[:notice] = "Successfully '#{participle}'d todo ##{params[:id]}"
      #redirect_to todos_url
    else
      render :action => 'edit'
    end
  end
  
  
  # episode 95 for Remote app with authentication
  # Episode 82 for multiple auth...
  def authorize_episode95
   # user = User.authenticate(params[:login], params[:password])
   # if user
   #   session[:user_id] = user.id
   #   flash[:notice] = "Logged in successfully."
    user = nil
    return authenticate_or_request_with_http_basic do |username, password|
      #username == "guest" && password == "guest"
      #user = 
      user = User.authenticate(username, password )
      if user
        session[:api_user_id] = user.id 
      end
      puts "\n\nDEBUG (API authorize_episode95): user='#{user.id rescue "NoId:"}'\n\n"
      return user
    end
    #if user
    #  session[:user_id] = user.id 
    #end
    # return user || login_required # passing to Ryan Bates thing..
  end
  
  
=begin
  # to DRY the methods for TODOS index and TODO show..
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
        :methods => [:due_explaination, :tag_list] ,
        :except => [:sys_notes]
    end  

end #/TodosController
