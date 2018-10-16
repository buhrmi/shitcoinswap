class AccessTokensController < ApplicationController
  skip_before_action :require_user, only: [:new, :create]

  def destroy
    cookies.delete(:access_token)
    current_access_token.update_attribute :logged_out_at, Time.now    
    @current_user = nil
    redirect_to login_path, notice: "Logged out!"
  end
end
