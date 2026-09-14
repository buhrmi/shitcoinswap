class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail to: user.email, subject: "Welcome to Shitcoin Swap"
  end

  def email_confirmation_code(email, code)
    @email = email
    @code = code
    mail to: email, subject: "Your Shitcoin Swap confirmation code"
  end

  def password_reset(user, token)
    @user = user
    @token = token
    mail to: user.email, subject: "Reset your password"
  end

  # Notifies the *previous* address that the account's email was changed, so
  # its owner can react if they didn't make the change.
  def email_changed(user, previous_email)
    @user = user
    @previous_email = previous_email
    mail to: previous_email, subject: "Your Shitcoin Swap email address was changed"
  end

  private

  # "250000.0" => "250,000", but keeps fractions like "0.5" intact.
  def format_amount(amount)
    amount = amount.to_d
    amount = amount.to_i if amount.frac.zero?
    ActiveSupport::NumberHelper.number_to_delimited(amount)
  end
end
