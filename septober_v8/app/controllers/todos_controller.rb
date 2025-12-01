class TodosController < ApplicationController
  before_action :login_required, unless: -> { request.format.json? }

  def index
    user_id = current_user&.id || User.first&.id # Fallback for CLI testing without auth
    filter_conditions = { user_id: user_id }
    if params[:add_project]
      project = Project.find_by(name: params[:add_project], user_id: current_user.id)
      filter_conditions[:project_id] = project.id if project
    else
      # TODO: Implement home_visible logic properly if needed
    end

    @todos = Todo.where(filter_conditions)
                 .search(params[:q])
                 .joins(:project)
                 .order(active: :desc, priority: :desc, updated_at: :desc)
                 .limit(20)

    respond_to do |format|
      format.html
      format.json { render json: @todos }
      format.xml  { render xml: @todos }
    end
  end

  def show
    @todo = Todo.find_by(id: params[:id], user_id: current_user.id)
    respond_to do |format|
      format.html
      format.json { render json: @todo }
      format.xml  { render xml: @todo }
    end
  end

  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)
    @todo.user = current_user
    if @todo.save
      flash[:notice] = "Successfully created todo ##{@todo.id} '#{@todo.to_s}'"
      redirect_to todos_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @todo = Todo.find_by(id: params[:id], user_id: current_user.id)
  end

  def update
    @todo = Todo.find(params[:id])
    if @todo.update(todo_params)
      flash[:notice] = "Successfully updated todo ##{@todo.id}"
      redirect_to todos_url
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
    flash[:notice] = "Successfully destroyed todo ##{@todo.id}."
    redirect_to todos_url
  end

  def toggle
    _update_active(:toggled)
  end

  def done
    _update_active(:deactivated, false)
  end

  def undone
    _update_active(:reactivated, true)
  end

  def set_priority
    _update_field(:priority, params[:new_priority])
  end

  def procrastinate
    n_days = params.fetch(:procrastinate_days, 7).to_i
    _update_field(:due, Date.today + n_days)
  end

  def sleep
    n_days = params.fetch(:hide_until_days, 8).to_i
    _update_field(:hide_until, Time.now + n_days.days)
  end

  private

  def _update_active(participle, new_active = nil)
    @todo = Todo.find_by(id: params[:id], user_id: current_user.id)
    new_active = !@todo.active if new_active.nil?
    
    if @todo.update(active: new_active)
      flash[:notice] = "Successfully '#{participle}' todo ##{params[:id]}"
      redirect_to todos_url
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def _update_field(field_name, new_val)
    @todo = Todo.find_by(id: params[:id], user_id: current_user.id)
    if @todo.update(field_name => new_val)
      flash[:notice] = "Successfully set '#{field_name}'='#{new_val}' for Todo ##{params[:id]}"
      redirect_to todos_url
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def todo_params
    params.require(:todo).permit(:name, :description, :active, :due, :priority, :project_id, :url, :progress_status, :favorite, :hide_until, :depends_on_id, :source, :photo_url, :tag_list)
  end
end
