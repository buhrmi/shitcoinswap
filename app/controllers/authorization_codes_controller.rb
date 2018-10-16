class AuthorizationCodesController < ApplicationController
  before_action :get_user,   only: [:edit]
  before_action :set_authorization_code, only: [:edit]
  before_action :check_unused, only: [:edit]
  before_action :check_expiration, only: [:edit]
  before_action :check_authorization, only: [:edit]
  skip_before_action :require_user

  # GET /authorization_codes
  # GET /authorization_codes.json
  # def index
  #   @authorization_codes = AuthorizationCode.all
  # end

  # GET /authorization_codes/1
  # GET /authorization_codes/1.json
  # def show
  # end

  # GET /authorization_codes/new
  def new
    @authorization_code = AuthorizationCode.new
  end

  # GET /authorization_codes/1/edit
  def edit
  end

  # POST /authorization_codes
  # POST /authorization_codes.json
  def create
    @user = User.find_or_create_by(email: params[:authorization_code][:email].downcase!)
    if @user.id === nil
      @user.password = @user.email
      @user.password_confirmation = @user.email
      @user.save
      # if @user.save
      #   logger.info "AC logs @user.save #{@user.email}"
      # else
      #   logger.info "USER NOT CREATED"
      # end
    end

    @authorization_code = AuthorizationCode.create(user_id: @user.id)

    @authorization_code.save
    # if @authorization_code.save
    #   logger.info "AC CREATED"

    # else
    #   logger.info "AC NOT CREATED"

    # end

    redirect_to root_url, notice: "Please check your email to login."
    # respond_to do |format|
    #   if @authorization_code.save
    #     format.html { redirect_to @authorization_code, notice: 'Authorization code was successfully created.' }
    #     format.json { render :show, status: :created, location: @authorization_code }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @authorization_code.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /authorization_codes/1
  # PATCH/PUT /authorization_codes/1.json
  # def update
  #   respond_to do |format|
  #     if @authorization_code.update(authorization_code_params)
  #       format.html { redirect_to @authorization_code, notice: 'Authorization code was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @authorization_code }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @authorization_code.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /authorization_codes/1
  # DELETE /authorization_codes/1.json
  # def destroy
  #   @authorization_code.destroy
  #   respond_to do |format|
  #     format.html { redirect_to authorization_codes_url, notice: 'Authorization code was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_authorization_code
    @authorization_code = AuthorizationCode.where(user_id: @user.id).last

    unless (@authorization_code && @authorization_code.authenticated?(params[:id]))
      redirect_to new_authorization_code_url, alert: "Authorization code not found. Please use the latest link sent to your email."
    end
  end

  def check_authorization
    @authorization_code.authorization_code_used
    access_token = @user.create_access_token!
    cookies[:access_token] = {value: access_token.token, http_only: true}
    flash[:success] = "Logged in!"
    redirect_to root_path
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def authorization_code_params
    params.require(:authorization_code).permit(:user_id, :token, :used_at)
  end


  # Checks expiration of reset token.
  def check_expiration
    if @authorization_code.authorization_code_expired?
      redirect_to new_authorization_code_url, alert: "Authorization code has expired."
    end
  end


  # Checks expiration of reset token.
  def check_unused
    if @authorization_code.is_used?
      redirect_to new_authorization_code_url, alert: "Authorization code was used. Please create a new one."
    end
  end

  def get_user
    @user = User.find_by(email: params[:email])
    if @user.nil?
      redirect_to new_authorization_code_url, alert: "User Not Found."
    end
  end
end
