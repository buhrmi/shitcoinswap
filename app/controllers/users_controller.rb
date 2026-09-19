# frozen_string_literal: true

class UsersController < ApplicationController
  # GET /users/new
  #
  # Without a verification_id this is the identity step: enter an email
  # address. With a verification_id pointing at a *verified* Verification it
  # becomes the final step, where the visitor picks a password.
  def new
    return unless params[:verification_id]

    verification = Verification.find_by(id: params[:verification_id])

    if verification&.verified? && !verification.expired?
      @verification = { id: verification.id, email: verification.email }
    elsif verification && !verification.expired?
      # Pending – send them to enter the code first.
      redirect_to verification_path(verification)
    else
      # Missing or expired – start over.
      redirect_to new_user_path
    end
  end

  # POST /users — final step: the email is verified and the visitor has chosen
  # a password. The account is created from the Verification record.
  def create
    verification = Verification.find_by(id: params[:verification_id])
    unless verification&.verified? && !verification.expired?
      return redirect_to new_user_path
    end

    user = User.new(
      email: verification.email,
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
    user.validate

    if user.errors[:email].any?
      # The address was taken between verification and submit.
      flash[:alert] = "That email is already registered. Please log in."
      redirect_to new_session_path
    elsif user.errors[:password].any? || user.errors[:password_confirmation].any?
      redirect_to new_user_path(verification_id: verification.id), inertia: {
        errors: user.errors.to_hash.slice(:password, :password_confirmation)
      }
    else
      create_user!(user)
    end
  end

  private

  def create_user!(user)
    user.save!
    session[:user_id] = user.id
    flash.now[:notice] = "Account created."
  end
end
