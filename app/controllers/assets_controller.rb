class AssetsController < ApplicationController
  def index
    @assets = Asset.all.as_json(Asset::JSON_OPTIONS)
  end

  # Either /assets/:id or /assets/:network/:contract.
  def show
    asset = params[:network_id] ? asset_on_network : Asset.find(params[:id])
    @asset = asset.as_json(Asset::JSON_OPTIONS)
  end

  def new
  end

  private

  def asset_on_network
    Network.find(params[:network_id]).assets.find_by!(contract_address: params[:id])
  end
end
