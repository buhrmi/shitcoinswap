class UsersController < ApplicationController
  include Passwordless::ControllerHelpers

  protect_from_forgery with: :exception

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # store all emails in lowercase to avoid duplicates and case-sensitive login errors:
    @user.email.downcase!

    if @user.save
      # If user saves in the db successfully:
      sign_in @user
      redirect_to root_path, flash:{notice: 'Welcome!'}
    else
      # If user fails model validation - probably a bad password or duplicate email:
      flash.now.alert = "Oops, something wroung and try again."
      render :new
    end
  end

  private

  def user_params
    # strong parameters - whitelist of allowed fields #=> permit(:name, :email, ...)
    # that can be submitted by a form to the user model #=> require(:user)
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
