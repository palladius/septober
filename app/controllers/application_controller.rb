class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  private

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.permanent.signed[:user_id]
      @current_user ||= User.find_by(id: cookies.permanent.signed[:user_id])
      session[:user_id] = @current_user.id if @current_user
    end
    @current_user
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    cookies.delete(:user_id)
    @current_user = nil
  end

  def logged_in?
    current_user.present?
  end

  def login_required
    unless logged_in?
      flash[:alert] = "You must be logged in to access this section"
      redirect_to login_path
    end
  end
  
  def redirect_to_target_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
