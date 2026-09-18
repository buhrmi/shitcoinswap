class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  use_inertia_instance_props


  rescue_from ActiveRecord::RecordInvalid do |exception|
    # raise exception unless request.inertia?
    errors = exception.record.errors

    flash[:alert] = errors.full_messages.first

    redirect_back inertia: {
      errors: exception.record.errors
    }
  end

  rescue_from ActionController::BadRequest do |exception|
    flash[:alert] = exception.message
    redirect_back(fallback_location: root_path, status: :see_other)
  end

  inertia_share do
    {
      assets: @assets = Asset.all,
      current_user_id: current_user && current_user.id,
      stream_token: current_user && DexieChannel.stream_token_for(current_user)
    }.compact
  end

  private

  def set_inertia_frame_header
    response["X-Inertia-Frame"] = session.delete(:inertia_frame) if session[:inertia_frame]
  end

  def redirect_back(**options)
    if inertia_referer = request.headers["X-Inertia-Referer"]
      session[:inertia_frame] = request.headers["X-Inertia-Frame"]
      redirect_to inertia_referer, **options, status: :see_other
    else
      super
    end
  end

  def current_user
    Current.user ||= session[:user_id] && User.find_by(id: session[:user_id])
  end
end
