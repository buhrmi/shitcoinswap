class TradesController < ApplicationController
  before_action :require_user
  def index
    @trades = Trade.joins("Inner join orders as buy_orders on buy_orders.id = trades.buy_order_id
							Inner join orders as sell_orders on sell_orders.id = trades.sell_order_id
							Inner join assets as base_assets on base_assets.id = buy_orders.base_asset_id
							Inner join assets as quote_assets on quote_assets.id = sell_orders.quote_asset_id")
    .select("trades.id,
							CASE WHEN buy_orders.kind = 'market' THEN CONCAT('Buy ', base_assets.name, '\n Price: Any \n Limit: ', CAST(ROUND(buy_orders.total, 6) AS FLOAT), ' ',quote_assets.name) ELSE 
								CONCAT('Buy ',CAST(ROUND(buy_orders.quantity,6) AS FLOAT), ' ', base_assets.name ,'\n Price: ', CAST(ROUND(buy_orders.price,6) AS FLOAT), ' ', quote_assets.name) END AS buy_order_,
							LEAST(trades.amount, sell_orders.quantity_filled, buy_orders.quantity_filled) as transaction_base,
							LEAST(sell_orders.price, buy_orders.price) as transaction_price,
							sell_orders.quantity_filled,
							buy_orders.quantity_filled,
						    buy_orders.quantity,
						    buy_orders.total,
						    sell_orders.quantity AS seller_order_quantity,
						    sell_orders.total_used,
						    sell_orders.price as sell_order_price,
						    base_assets.name as base_asset_name,
						    quote_assets.name as quote_asset_name,
						    CASE WHEN sell_orders.kind = 'market' THEN CONCAT('Sell ', base_assets.name, '\n Price: Any \n Limit: ', CAST(ROUND(sell_orders.quantity, 6) AS FLOAT), ' ', base_assets.name) ELSE 
						    	CONCAT('Sell ', base_assets.name, '\n Price: ', CAST(ROUND(sell_orders.price,6) AS FLOAT), ' ', quote_assets.name, '\n Limit: ', CAST(ROUND(sell_orders.quantity, 6) AS FLOAT), ' ', base_assets.name) END AS sell_order_,
						    CASE WHEN buy_orders.kind = 'market' THEN ROUND((buy_orders.total_used/buy_orders.total) * 100, 2) ELSE ROUND((buy_orders.quantity_filled/buy_orders.quantity) * 100, 2) END AS buy_order_percentage,
						    CONCAT(ROUND((sell_orders.quantity_filled/sell_orders.quantity) * 100, 1), '% Sold')  AS sell_order_percentage,
						    CASE WHEN buy_orders.cancelled_at IS NOT NULL OR (buy_orders.kind = 'market' AND buy_orders.total_used = buy_orders.total) OR (buy_orders.kind != 'market' AND buy_orders.quantity_filled = buy_orders.quantity) THEN ' - Closed' ELSE ' - Opened' END AS buy_order_status,
						    CASE WHEN sell_orders.cancelled_at IS NOT NULL OR sell_orders.quantity_filled = sell_orders.quantity THEN ' - Closed' ELSE ' - Opened' END AS sell_order_status")
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
