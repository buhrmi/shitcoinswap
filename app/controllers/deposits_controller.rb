class DepositsController < ApplicationController
  def new
    @asset = Asset.find(params[:asset_id])
    @address = current_user.addresses.where(module: @asset.platform.module).first_or_create!
  end

  def create
    platform = Platform.find(params[:platform_id])
    block = params[:block].to_i
    
    count = Deposit.count
    platform.scan_for_deposits!(block, block)
    count_new = Deposit.count

    redirect_back fallback_location: root_url, notice: "Block #{block} rescanned. #{count_new - count} new deposits have been created."
  end
end
