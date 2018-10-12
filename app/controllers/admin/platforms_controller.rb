class Admin::PlatformsController < ApplicationController
  before_action :require_user!
  def index
    @platforms = Platform.all
  end
end
