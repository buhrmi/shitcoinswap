class Admin::AssetsController < ApplicationController
  before_action :require_admin
  
  def index
    @assets = Asset.all
  end
end