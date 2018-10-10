class UserMailer < ApplicationMailer
  def deposit_email
    @user = params[:user]
    @deposit = params[:deposit]
    mail(to: @user.email, subject: "New Deposit: #{@deposit.amount} #{@deposit.coin.name} have been deposited")
  end

  def withdrawal_submitted_email
    @user = params[:user]
    @withdrawal = params[:withdrawal]
    mail(to: @user.email, subject: "Deposit cancelled: #{@withdrawal.amount} #{@withdrawal.coin.name} have been withdrawn")
  end
end
