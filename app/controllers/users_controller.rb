# encoding: utf-8
class UsersController < ApplicationController
  before_filter :login_required, :except => [:new, :create]
  
  can_edit_on_the_spot

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if logged_in? && @user.parent_id == current_user.id
      @user.is_agent = true
      if @user.save
        flash[:notice] = "Successfully provisioned sub-agent #{@user.agent_icon} #{@user.username}!"
        redirect_to edit_current_user_path
      else
        flash[:error] = "Failed to provision agent: #{@user.errors.full_messages.join(', ')}"
        redirect_to edit_current_user_path
      end
    elsif @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Thank you for signing up! You are now logged in."
      redirect_to "/"
    else
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Your profile has been updated."
      redirect_to "/"
    else
      render :action => 'edit'
    end
  end
  
  def show
    @user = User.find(params[:id])
  end
end
