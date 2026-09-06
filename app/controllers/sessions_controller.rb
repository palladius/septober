class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      cookies.permanent.signed[:user_id] = user.id if params[:remember_me] == "1" || params[:remember_me] == true
      flash[:notice] = "Logged in successfully."
      redirect_to_target_or_default root_path
    else
      flash.now[:alert] = "Invalid login or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.delete(:user_id)
    flash[:notice] = "You have been logged out."
    redirect_to root_path
  end
end
