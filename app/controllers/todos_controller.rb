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
    _normalize_todo_params!(params[:todo])
    params[:todo][:user_id] = current_user.id
    @todo = Todo.new(params[:todo])
    if @todo.save
      flash[:notice] = "Successfully created todo ##{@todo.id} '#{@todo.to_s}'"
      if params[:from_modern_form].present?
        redirect_to todo_path(@todo)
      else
        redirect_to todos_url
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @todo = Todo.find_securely(current_user,params[:id])
  end

  def update
    @todo = Todo.find_securely(current_user, params[:id])
    todo_attrs = _normalize_todo_params!(params[:todo] || {})
    saved = @todo.update_attributes(todo_attrs)

    # Fallback for vintage todos whose legacy duplicate name might fail unrelated validations
    # when inline-updating non-name scalar fields within valid bounds.
    allowed_direct = %w{progress_status priority description url where due favorite active hide_until depends_on_id photo_url project_id}
    attr_keys = todo_attrs.keys.map(&:to_s)
    if !saved && attr_keys.any? && !attr_keys.include?('name') && (attr_keys - allowed_direct).empty?
      direct_updates = {}
      bounds_ok = true
      attr_keys.each do |k|
        raw_v = todo_attrs.key?(k.to_sym) ? todo_attrs[k.to_sym] : todo_attrs[k]
        case k
        when 'progress_status'
          pv = raw_v.to_i
          bounds_ok = false unless (0..100).include?(pv)
          direct_updates[:progress_status] = pv
        when 'priority'
          prv = raw_v.to_i
          bounds_ok = false unless (1..5).include?(prv)
          direct_updates[:priority] = prv
        when 'favorite', 'active'
          direct_updates[k.to_sym] = (raw_v == true || raw_v.to_s == 'true' || raw_v.to_s == '1')
        when 'project_id'
          fam_ids = current_user.respond_to?(:family_user_ids) ? current_user.family_user_ids : [current_user.id]
          proj = Project.find_by_id(raw_v.to_i)
          if proj && (fam_ids + [@todo.user_id]).compact.include?(proj.user_id)
            direct_updates[:project_id] = proj.id
          else
            bounds_ok = false
          end
        when 'depends_on_id'
          dep_id = raw_v.blank? ? nil : raw_v.to_i
          bounds_ok = false if dep_id && dep_id == @todo.id
          direct_updates[:depends_on_id] = dep_id
        else
          direct_updates[k.to_sym] = raw_v
        end
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
        render :json => _todo_inline_json_payload(@todo)
      else
        flash[:notice] = "Todo ##{@todo.id} aggiornato con successo"
        redirect_to todo_path(@todo)
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
  def _normalize_todo_params!(attrs)
    return {} unless attrs.is_a?(Hash)
    [:due, 'due', :depends_on_id, 'depends_on_id'].each do |k|
      if attrs.key?(k) && attrs[k].is_a?(String) && attrs[k].strip.empty?
        attrs[k] = nil
      end
    end
    [:hide_until, 'hide_until'].each do |k|
      next unless attrs.key?(k)
      val = attrs[k]
      if val.is_a?(String)
        stripped = val.strip
        if stripped.empty?
          attrs[k] = nil
        elsif stripped =~ /\A(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})(?::(\d{2}))?\z/
          sec = $3 || '00'
          attrs[k] = "#{$1} #{$2}:#{sec}"
        end
      end
    end
    attrs
  end

  def _todo_inline_json_payload(todo)
    vc = (view_context rescue nil)
    desc_html, prov_line = (vc ? vc.format_todo_description_parts(todo) : [nil, nil]) rescue [nil, nil]
    url_html    = (vc ? vc.render_todo_clickable_url(todo) : nil) rescue nil
    due_html    = (vc ? vc.render_todo_show_due(todo) : todo.due.to_s) rescue todo.due.to_s
    maps_aerial = (todo.where? && vc) ? (vc.todo_google_maps_embed_url(todo.where, true, 16) rescue nil) : nil
    maps_road   = (todo.where? && vc) ? (vc.todo_google_maps_embed_url(todo.where, false, 15) rescue nil) : nil
    maps_ext    = (todo.where? && vc) ? (vc.todo_google_maps_external_url(todo.where) rescue nil) : nil
    tags_data   = (todo.tags.map { |t| { :id => t.id, :name => t.name.to_s } } rescue [])

    {
      :ok => true,
      :id => todo.id,
      :name => todo.name.to_s,
      :description => todo.description.to_s,
      :desc_html => desc_html,
      :provenance_line => prov_line,
      :url => todo.url.to_s,
      :url_html => url_html,
      :where => todo.where.to_s,
      :maps_aerial_url => maps_aerial,
      :maps_road_url => maps_road,
      :maps_ext_url => maps_ext,
      :due => (todo.due ? todo.due.strftime('%Y-%m-%d') : ''),
      :due_html => due_html,
      :is_overdue => (!todo.done? && todo.overdue?),
      :is_done => todo.done?,
      :active => !!todo.active,
      :favorite => !!todo.favorite,
      :priority => todo.priority,
      :google_priority => (5 - todo.priority.to_i),
      :progress_status => todo.progress_status,
      :project_id => todo.project_id,
      :project_name => (todo.project ? todo.project.name.to_s : ''),
      :project_color => (todo.project ? todo.project.color.to_s : ''),
      :tag_list => (todo.tag_list.to_a rescue []),
      :tags => tags_data,
      :hide_until => (todo.hide_until ? todo.hide_until.strftime('%Y-%m-%dT%H:%M') : ''),
      :depends_on_id => todo.depends_on_id,
      :photo_url => todo.photo_url.to_s
    }
  end

end #/TodosController
