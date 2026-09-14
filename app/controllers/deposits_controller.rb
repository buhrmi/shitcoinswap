class DepositsController < ApplicationController
  def new
    asset = Asset.find(params[:asset_id])
    @wallet = current_user.wallets.asset(asset).first_or_create!.as_json
    @asset = asset.as_json
  end
end
