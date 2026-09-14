class WalletsController < ApplicationController
  def show
    asset = Asset.find(params[:asset_id])
    @wallet = current_user.wallets.asset(asset).first_or_create!
  end
end
