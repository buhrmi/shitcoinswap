class SessionsController < ApplicationController
  def new
    render layout: false if params[:provider]
  end

  def create
    if request.env["omniauth.auth"].present?
      create_from_omniauth
    else
      create_from_email
    end
  end

  def create_from_email
    if current_user
      flash[:alert] = "You are already signed in."
      redirect_back fallback_location: root_path
    end
    Current.user = User.authenticate_by(
      email: params[:email].to_s.downcase,
      password: params[:password]
    )
    if Current.user
      session[:user_id] = Current.user.id
      flash.now[:notice] = "Successfully logged in."
    else
      flash[:alert] = "Invalid email or password."
      redirect_back fallback_location: new_session_path
    end
  end

  def create_from_omniauth
    auth = request.env["omniauth.auth"]

    identity = Identity.from_omniauth!(auth, current_user)

    if current_user
      if identity.user != current_user
        flash[:alert] = "This #{identity.provider} account is already connected to another user."
        return
      else
        flash[:notice] = "Successfully connected your #{identity.provider} account."
        return
      end
    end

    session[:user_id] = identity.user_id

    if identity.previously_new_record?
      flash[:notice] = "Account created."
    else
      flash[:notice] = "Successfully logged in."
    end
  rescue StandardError => e
    flash[:alert] = e.message
  ensure
    render layout: false
  end

  def destroy
    session.delete(:user_id)
    flash.now[:notice] = "Logged out"
    Current.user = nil
  end

  def failure
    flash[:alert] = "Authentication failed: #{params[:message] || 'Unknown error'}"
    redirect_to new_session_path
  end
end
