class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update]
  before_action :require_user

  # GET /users/1/edit
  def edit
    @email = current_user.email
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to "/users/edit", notice: 'Email was successfully updated.' }
        format.json { render :edit, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = current_user
  end

  # # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email)
  end
end
