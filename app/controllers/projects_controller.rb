class ProjectsController < ApplicationController
  before_filter :login_required #, :except => [:index, :show]
  def index
    @projects = Project.find_all_by_user_id(current_user.id)
  end

  def show
    @project = Project.find(params[:id])
  end

  def new
    @project = Project.new
  end

  def create
    params[:project][:user_id] = current_user.id
    #params[:project][:description] = 'ovverridden by ctrler!'
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = "Successfully created project."
      #redirect_to @project
      redirect_to projects_url
    else
      render :action => 'new'
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    #@project.tag_with(params[:magic_tag_list])
    if @project.update_attributes(params[:project])
      flash[:notice] = "Successfully updated project."
      #redirect_to project_url
      #redirect_to todos_url
      redirect_to projects_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    flash[:notice] = "Successfully destroyed project."
    redirect_to projects_url
  end
  
  ########################################################################
  # Ste due funzioni sono dal tagging content delle RailsREcipes (penso libro2) pag 75
  #
  def tag 
    project = Project.find(params[:id]) 
    project.tag_with(params[:tag_list]) 
    project.save 
    render :partial => "content", :locals => {:project => project, :form_id => params[:form_id]}
  end
  def list 
    @contacts = Contact.search(params[:search]).order(sort_column + " " + sort_direction).paginate(:per_page => 5, :page => params[:page])
    #@contacts = if tag_name = params[:id]
    #  Tag.find_by_name(tag_name).tagged
    #else
    #  Contact.find(:all)
    #end 
  end
  # /Tags stuff
  ########################################################################
end
