class ApplicationController < ActionController::Base
  before_action :require_user

  protect_from_forgery with: :exception

  # Make the current_user method available to views also, not just controllers:
  helper_method :current_user

  # Define the current_user method:
  def current_user
    # Look up the current user based on user_id in the session cookie:
    
    @current_user ||= User.joins(:sessions).find_by(sessions: {authorization: cookies[:authorization]})
  end

  # authroize method redirects user to login page if not logged in:
  def require_user
    if current_user.nil?
      cookies[:continue_to] = request.path
      redirect_to login_path, alert: 'You must be logged in to access this page.'
    end
  end
end
