class VerificationsController < ApplicationController
  # POST /verifications
  def create
    email = params[:email].to_s.strip

    user = User.new(user_params)

    user.validate!

    if User.exists?(email: email)
      flash[:alert] = "That email is already registered. Please log in."
      return redirect_to new_session_path
    end

    Verification.expire_pending_for!(email)

    verification = Verification.create!(kind: "email", email: email)
    UserMailer.email_confirmation_code(email, verification.code).deliver_later

    redirect_to verification_path(verification), notice: "Code sent"
  end

  # GET /verifications/:id
  def show
    verification = Verification.find_by(id: params[:id])

    unless verification
      flash[:alert] = "This verification link is invalid."
      return redirect_to new_user_path
    end

    return redirect_to new_user_path(verification_id: verification.id) if verification.verified?

    if verification.expired?
      flash[:alert] = "That code expired. Please start again."
      return redirect_to new_user_path
    end

    @verification = { id: verification.id, email: verification.email }
  end

  # PATCH /verifications/:id
  def update
    verification = Verification.find_by(id: params[:id])

    unless verification
      flash[:alert] = "This verification link is invalid."
      return redirect_to new_user_path
    end

    case verification.confirm!(params[:code])
    when :verified
      redirect_to new_user_path(verification_id: verification.id)
    when :expired
      flash[:alert] = "That code expired. Please start again."
      redirect_to new_user_path
    else
      redirect_to verification_path(verification), inertia: { errors: { code: "is invalid" } }
    end
  end

  private
  def user_params
    params.with_defaults(password: SecureRandom.base58(8)).permit(:email, :password)
  end
end
