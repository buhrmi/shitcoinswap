class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers

  # Make the current_user method available to views also, not just controllers:
  helper_method :current_user

  # Define the current_user method:
  def current_user
    @current_user ||= authenticate_by_cookie(User)
  end

  # authroize method redirects user to login page if not logged in:
  def require_user!
    return if current_user
    save_passwordless_redirect_location!(User)
    redirect_to root_path, alert: 'You are not logged in!'
  end
end
