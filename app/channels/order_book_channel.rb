class OrderBookChannel < ApplicationCable::Channel
  def subscribed
    stream_from "order_book_#{params[:base_asset_id]}_#{params[:quote_asset_id]}"
  end
end