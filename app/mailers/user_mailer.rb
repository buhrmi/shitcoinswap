class UserMailer < ApplicationMailer
  def deposit_email
    @user = params[:user]
    @deposit = params[:deposit]
    @branding = params[:branding]
    from = @branding ? "#{@branding.name} Support <support@#{@branding.domain}>" : "Shitcoins Japan <support@shitcoins.jp>"
    I18n.with_locale @user.locale do
      mail(to: @user.email, subject: default_i18n_subject(amount: @deposit.amount, asset_name: @deposit.asset.name))
    end
  end

  def withdrawal_submitted_email
    @user = params[:user]
    @withdrawal = params[:withdrawal]
    @branding = params[:branding]
    from = @branding ? "#{@branding.name} Support <support@#{@branding.domain}>" : "Shitcoins Japan <support@shitcoins.jp>"
    I18n.with_locale @user.locale do
      mail(to: @user.email, subject: default_i18n_subject(amount: @withdrawal.amount, asset_name: @withdrawal.asset.name))
    end
  end

  def airdrop
    @user = params[:user]
    @adjustment = params[:adjustment]
    @branding = params[:branding]
    from = @branding ? "#{@branding.name} Support <support@#{@branding.domain}>" : "Shitcoins Japan <support@shitcoins.jp>"
    I18n.with_locale @user.locale do
      mail(to: @user.email, subject: default_i18n_subject(amount: @adjustment.amount, asset_name: @adjustment.asset.name))
    end
  end

  def authorization_code
    @user = params[:user]
    @auth_code = params[:auth_code]
    @branding = params[:branding]
    from = @branding ? "#{@branding.name} Support <support@#{@branding.domain}>" : "Shitcoins Japan <support@shitcoins.jp>"
    I18n.with_locale @user.locale do
      mail to: @user.email, from: from
    end
  end
end
