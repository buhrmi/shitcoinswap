class AuthorizationCodesController < ApplicationController
  skip_before_action :require_user

  # GET /authorization_codes/new
  def new
    @authorization_code = AuthorizationCode.new
  end

  # POST /authorization_codes
  # POST /authorization_codes.json
  def create
    user = User.find_or_create_by!(email: params[:authorization_code][:email].downcase)
    auth = AuthorizationCode.create!(user: user)
    UserMailer.with(user: user, auth_code: auth.code, branding: current_brand_asset).authorization_code.deliver_now
    redirect_to page_url(:link_sent)
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def authorization_code_params
    params.require(:authorization_code).permit(:auth_code, :email)
  end
end
