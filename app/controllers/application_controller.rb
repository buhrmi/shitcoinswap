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
    return unless auth_code = params[:auth_code]
    
    @authorization_code = AuthorizationCode.find_by(code: auth_code)

    unless @authorization_code
      redirect_to login_url, alert: "Authorization code not found. Please use the latest link sent to your email."
      return
    end

    # Check if the authorization code is used
    if @authorization_code.used?
      redirect_to login_url, alert: "Authorization code was used. Please create a new one."
      return
    end

    # Check if the authorization code is expired
    if @authorization_code.expired?
      redirect_to login_url, alert: "Authorization code has expired."
      return
    end

    # Check if the authorization code is valid
    access_token = @authorization_code.trade_for_token!
    cookies[:access_token] = {value: access_token.token, http_only: true}
    redirect_to root_path, notice: "Logged in!"
  end
end
