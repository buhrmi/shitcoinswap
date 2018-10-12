class DepositsController < ApplicationController
  def new
    @asset = Asset.find(params[:asset_id])
    @address = current_user.addresses.where(module: @asset.platform.module).first_or_create!
  end
end
