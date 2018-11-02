class OrdersController < ApplicationController

  def index
    @open_orders = current_user.orders.open
    @past_orders = current_user.orders.closed
  end

  def new
    @order = Order.new(order_params)
    @asset = @order.base_asset
    @order.quote_asset ||= current_quote_asset
    # TODO: make a new orderbook endpoint instead of listing orders
    @open_orders = @asset.orders.open.where(quote_asset_id: current_quote_asset.id)
  end

  def create
    @order = Order.new(order_params)
    @asset = @order.base_asset
    # TODO: make a new orderbook endpoint instead of listing orders
    @open_orders = @asset.orders.open.where(quote_asset_id: current_quote_asset.id)
    @order.user = current_user

    respond_to do |format|
      if @order.save
        @order.process!
        format.js {  } # TODO: render a "order created" popup
        format.html { redirect_back fallback_location: new_order_path(order: {asset_id: @asset.id}), notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.js { render js: "alert('#{@order.errors.full_messages}')" } # TODO: render a "error" popup
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order = current_user.orders.find(params[:id])
    @order.cancel!

    respond_to do |format|
      format.js {  } # TODO: render a "order cancelled" popup
      format.html { redirect_back fallback_location: orders_path, notice: 'Order was successfully cancelled.' }
      format.json { render :show, status: :destroyed, location: @order }    
    end
  end

  private

  def order_params
    params.require(:order).permit(:base_asset_id, :quote_asset_id, :side, :kind, :quantity, :rate, :total)
  end
end
