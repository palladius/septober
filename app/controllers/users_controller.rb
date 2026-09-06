class UsersController < ApplicationController
  before_action :login_required, except: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if logged_in? && @user.parent_id == current_user.id
      @user.is_agent = true
      if @user.save
        flash[:notice] = "Successfully provisioned sub-agent #{@user.resolved_agent_icon} #{@user.username}!"
        redirect_to edit_user_path(current_user)
      else
        flash[:alert] = "Failed to provision agent: #{@user.errors.full_messages.join(', ')}"
        redirect_to edit_user_path(current_user)
      end
    elsif @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Thank you for signing up! You are now logged in."
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash[:notice] = "Your profile has been updated."
      redirect_to root_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :description, :parent_id, :is_agent, :agent_host, :agent_icon)
  end
end
