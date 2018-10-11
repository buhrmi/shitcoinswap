class Admin::PlatformsController < ApplicationController
  def index
    @platforms = Platform.all
  end
end