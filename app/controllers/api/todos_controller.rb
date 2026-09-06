class Api::TodosController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_user

  def index
    allowed_ids = current_api_user.family_user_ids
    if params[:agent_id].present?
      target_id = params[:agent_id].to_i
      query_ids = allowed_ids.include?(target_id) ? [target_id] : []
    elsif params[:user_id].present?
      target_id = params[:user_id].to_i
      query_ids = allowed_ids.include?(target_id) ? [target_id] : []
    else
      query_ids = allowed_ids
    end

    scope = Todo.where(user_id: query_ids).joins(:project)
    if params[:add_project].present?
      project = Project.find_by(name: params[:add_project], user_id: allowed_ids)
      scope = scope.where(project_id: project.id) if project
    end

    @todos = scope.order(active: :desc, priority: :desc, updated_at: :desc).limit((params[:limit] || 50).to_i)

    respond_to do |format|
      format.json { render json: @todos.as_json(include: { project: { only: [:name, :color] }, user: { only: [:id, :username, :is_agent, :agent_icon, :agent_host] } }, methods: [:due_explaination, :tag_list]) }
      format.xml  { render xml: @todos }
    end
  end

  def show
    allowed_ids = current_api_user.family_user_ids
    @todo = Todo.where(user_id: allowed_ids).find_by(id: params[:id])
    if @todo
      render json: @todo.as_json(include: { project: { only: [:name, :color] }, user: { only: [:id, :username, :is_agent, :agent_icon, :agent_host] } }, methods: [:due_explaination, :tag_list])
    else
      render json: { error: "Todo not found" }, status: :not_found
    end
  end

  def create
    todo_data = params[:todo] || params
    permitted = todo_data.permit(:name, :description, :active, :due, :priority, :project_id, :url, :progress_status, :where, :source, :photo_url)
    
    @todo = Todo.new(permitted)
    @todo.user_id = current_api_user.id
    @todo.apply_todo_regex_magic rescue nil

    if @todo.save
      render json: @todo.as_json(include: { project: { only: [:name, :color] }, user: { only: [:id, :username, :is_agent, :agent_icon, :agent_host] } }), status: :created
    else
      render json: { error: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def toggle
    _update_active(nil)
  end

  def done
    _update_active(false)
  end

  def undone
    _update_active(true)
  end

  def destroy
    allowed_ids = current_api_user.family_user_ids
    @todo = Todo.where(user_id: allowed_ids).find_by(id: params[:id])
    if @todo&.destroy
      render json: { message: "Successfully destroyed todo ##{params[:id]}" }
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end

  private

  def current_api_user
    @current_api_user
  end

  def _update_active(new_active)
    allowed_ids = current_api_user.family_user_ids
    @todo = Todo.where(user_id: allowed_ids).find_by(id: params[:id])
    return render json: { error: "Not found" }, status: :not_found unless @todo

    new_active = !@todo.active if new_active.nil?
    if @todo.update(active: new_active)
      render json: @todo
    else
      render json: { error: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def authenticate_api_user
    authenticate_or_request_with_http_basic do |username, password|
      @current_api_user = User.authenticate(username, password)
      @current_api_user.present?
    end
  end
end
