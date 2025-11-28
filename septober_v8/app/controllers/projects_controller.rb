class ProjectsController < ApplicationController
  before_action :login_required

  def index
    @projects = Project.owned_by(current_user)
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    if @project.save
      flash[:notice] = "Successfully created project."
      redirect_to projects_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      flash[:notice] = "Successfully updated project."
      redirect_to projects_url
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    flash[:notice] = "Successfully destroyed project."
    redirect_to projects_url
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, :color, :active, :home_visible, :public, :photo_url)
  end
end
