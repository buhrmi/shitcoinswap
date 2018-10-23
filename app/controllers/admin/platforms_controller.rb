class Admin::PlatformsController < ApplicationController
  before_action :require_admin
  
  def index
    @platforms = Platform.all
  end
end