# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :check_auth_code
  before_action :require_user
  before_action :set_locale

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

  def require_admin
    raise_not_found unless current_user.try(:admin?)
  end

  def raise_not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def set_locale
    if params[:locale]
      cookies.permanent[:locale] = params[:locale]
      current_user.update_attributes(preferred_locale: params[:locale]) if current_user.try(:persisted?)
      return redirect_back fallback_location: root_url
    elsif params[:fb_locale]
      locale = params[:fb_locale]
    elsif current_user && current_user.preferred_locale
      locale = current_user.preferred_locale
    elsif cookies[:locale]
      locale = cookies[:locale]
    else
      locale = request.headers['Accept-Language'][0..1] if request.headers['Accept-Language']
    end

    if locale && I18n.config.available_locales.include?(locale.intern)
      I18n.locale = locale
    end
  end

  # check if auth_code & email in url
  def check_auth_code
    return unless auth_code = params[:auth_code]
    
    @authorization_code = AuthorizationCode.find_by(code: auth_code)

    unless @authorization_code
      redirect_to login_url, alert: "This link has already been used or is invalid. Please request a new link."
      return
    end

    # Check if the authorization code is used
    if @authorization_code.used?
      redirect_to login_url, alert: "This link has already been used or is invalid. Please request a new link."
      return
    end

    # Check if the authorization code is expired
    if @authorization_code.expired?
      redirect_to login_url, alert: "This link is expired. Please request a new link."
      return
    end

    access_token = @authorization_code.trade_for_token!
    cookies[:access_token] = {value: access_token.token, http_only: true}
    redirect_to root_path, notice: "Logged in!"
  end
end
