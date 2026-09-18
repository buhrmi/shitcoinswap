class AssetsController < ApplicationController
  def index
  end

  # Either /assets/:id or /assets/:network/:contract.
  def show
    @asset = params[:network_id] ? asset_on_network : Asset.find(params[:id])
  end

  def new
  end

  private

  def asset_on_network
    Network.find(params[:network_id])
      .assets.find_by!(contract_address: params[:id])
  end
end
