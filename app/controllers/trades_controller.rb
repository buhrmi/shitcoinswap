class TradesController < ApplicationController
  before_action :require_user
  def index
    # XXX: remove plaintext query as much as possible and use activerecord
    @trades = Trade.joins("Inner join orders as buy_orders on buy_orders.id = trades.buy_order_id
							Inner join orders as sell_orders on sell_orders.id = trades.sell_order_id
							Inner join assets as base_assets on base_assets.id = buy_orders.base_asset_id
							Inner join assets as quote_assets on quote_assets.id = sell_orders.quote_asset_id")
    .select("trades.id,
							trades.amount as transaction_base,
							trades.price as transaction_price,
						    base_assets.name as base_asset_name,
						    quote_assets.name as quote_asset_name,
						    trades.created_at,
						    trades.price,
						    CASE WHEN buy_orders.user_id != trades.seller_id THEN '+ ' ELSE '- ' END AS base_type,
						    CASE WHEN sell_orders.user_id != trades.buyer_id THEN '- ' ELSE '+ ' END AS quote_type")
    .where("(trades.buyer_id != trades.seller_id) AND (trades.seller_id = :userId OR trades.buyer_id = :userId)", {userId:current_user.id})
    .order('trades.id desc')
    if params[:asset_id]
      @trades = @trades.where(["trades.base_asset_id = :assetId", {assetId:params[:asset_id]}])
      @asset = Asset.find(params[:asset_id])
    end
    @trades = @trades.page(params[:page])
  end

  private


  # Never trust parameters from the scary internet, only allow the white list through.
  def trade_params
    params.require(:trade).permit(:asset_id)
  end
end
