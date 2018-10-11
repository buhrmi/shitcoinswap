class SessionsController < ApplicationController
  skip_before_action :require_user, only: [:new, :create]

  def new
    # No need for anything in here, we are just going to render our
    # new.html.erb AKA the login page
  end

  def create
    # Look up User in db by the email address submitted to the login form and
    # convert to lowercase to match email in db in case they had caps lock on:
    user = User.find_by(email: params[:login][:email].downcase)
      
    # Verify user exists in db and run has_secure_password's .authenticate()
    # method to see if the password submitted on the login form was correct:
    if user && user.authenticate(params[:login][:password])
      
      session = user.create_session!
      if params[:login][:remember_me] == '1'
        cookies.permanent[:authorization] = {value: session.authorization, http_only: true}
      else
        cookies[:authorization] = {value: session.authorization, http_only: true}
      end
      
      redirect_to cookies.delete(:continue_to) || root_path, notice: 'Successfully logged in!'
    else
      # if email or password incorrect, re-render login page:
      flash.now.alert = "Incorrect email or password, try again."
      render :new
    end
  end

  def destroy
    cookies.delete(:authorization)
    @current_user = nil
    redirect_to login_path, notice: "Logged out!"
  end
end
