class AuthorizationCodesController < ApplicationController
  skip_before_action :require_user

  # GET /authorization_codes/new
  def new
    @authorization_code = AuthorizationCode.new
  end

  # GET /authorization_codes/1/edit
  def edit

    # Get user from params
    @user = User.find_by(email: params[:email])
    if @user.nil?
      redirect_to login_url, alert: "User Not Found."
      return
    end

    # Set authourization code
    @authorization_code = AuthorizationCode.where(user_id: @user.id).last

    unless (@authorization_code && @authorization_code.authenticated?(params[:id]))
      redirect_to login_url, alert: "Authorization code not found. Please use the latest link sent to your email."
      return
    end

    # Check if the authorization code is used
    if @authorization_code.is_used?
      redirect_to login_url, alert: "Authorization code was used. Please create a new one."
      return
    end

    # Check if the authorization code is expired
    if @authorization_code.authorization_code_expired?
      redirect_to login_url, alert: "Authorization code has expired."
      return
    end

    # Check if the authorization code is valid
    @authorization_code.authorization_code_used
    access_token = @user.create_access_token!
    cookies[:access_token] = {value: access_token.token, http_only: true}
    redirect_to root_path, notice: "Logged in!"
  end

  # POST /authorization_codes
  # POST /authorization_codes.json
  def create
    @user = User.find_or_create_by(email: params[:authorization_code][:email].downcase!)
    if @user.id === nil
      @user.password = @user.email
      @user.password_confirmation = @user.email
      @user.save
    end

    @authorization_code = AuthorizationCode.create(user_id: @user.id)

    @authorization_code.save

    redirect_to root_url, notice: "Please check your email to login."
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def authorization_code_params
    params.require(:authorization_code).permit(:auth_code, :email)
  end
end
