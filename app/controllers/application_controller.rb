# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_auth_code
  before_action :require_user

  protect_from_forgery with: :exception

  # Make the current_user method available to views also, not just controllers:
  helper_method :current_user

  # Define the current_user method:
  def current_user
    # Look up the current user based on user_id in the access_token cookie:
    @current_user ||= current_access_token.try(:user)
  end

  def current_access_token
    @current_access_token ||= AccessToken.joins(:user).find_by(token: cookies[:access_token])
  end

  # authroize method redirects user to login page if not logged in:
  def require_user
    if current_user.nil?
      cookies[:continue_to] = request.path
      redirect_to login_path, alert: 'You must be logged in to access this page.'
    end
  end

  # check if auth_code & email in url
  def check_auth_code
    return true if params[:auth_code].nil? || params[:email].nil?
    redirect_to edit_authorization_code_url(params[:auth_code], email: params[:email])
  end
end
