# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  # Reset tokens are stored as `PasswordReset` rows (SHA-256 token digest plus
  # an expiry). The plaintext token is generated the same way `has_secure_token`
  # does (SecureRandom.base58(24)) and is only ever sent over email.

  # before_action :require_modal, only: [ :show ]

  def new
  end

  def create
    # Logged-in users reset their own password, so their address isn't asked
    # for again; everyone else supplies one in the form.
    email = (current_user&.email || params[:email]).to_s.downcase
    user = email.present? ? User.find_by(email: email) : nil
    if user
      token = PasswordReset.generate_for(user)
      UserMailer.password_reset(user, token).deliver_later
    end

    # Don't reveal whether an account exists for the given email.
    flash.now[:notice] = "If an account exists for that email, we've sent you a link to reset your password."
  end

  def show
    @token = params[:id]
    unless PasswordReset.find_by_token(@token)
      flash[:alert] = "This password reset link is invalid or has expired."
      redirect_to new_password_reset_path
    end
  end

  def destroy
    reset = PasswordReset.find_by_token(params[:id])
    unless reset
      flash[:alert] = "This password reset link is invalid or has expired."
      return redirect_to new_password_reset_path, status: :see_other
    end

    reset.user.update!(password: params[:password], password_confirmation: params[:password_confirmation])

    # Invalidate the token so it can't be reused.
    reset.consume!

    flash.now[:notice] = "Your password has been reset successfully."
  end
end
