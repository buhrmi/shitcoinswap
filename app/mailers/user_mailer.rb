class UserMailer < ApplicationMailer
  def deposit_email
    @user = params[:user]
    @deposit = params[:deposit]
    mail(to: @user.email, subject: "New Deposit: #{@deposit.amount} #{@deposit.asset.name} have been deposited")
  end

  def withdrawal_submitted_email
    @user = params[:user]
    @withdrawal = params[:withdrawal]
    mail(to: @user.email, subject: "Deposit cancelled: #{@withdrawal.amount} #{@withdrawal.asset.name} have been withdrawn")
  end


  def password_reset(user)
    @user = user
    mail to: @user.email, subject: "Password reset"
  end


  def authorization_code
    @user = params[:user]
    @token = params[:token]
    mail to: @user.email, subject: "Login email"
  end
end
