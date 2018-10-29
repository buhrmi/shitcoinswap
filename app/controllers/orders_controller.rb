class OrdersController < ApplicationController

  def index
    @open_orders = current_user.orders.open
    @past_orders = current_user.orders.closed
  end

  def new
    @order = Order.new(order_params)
    @asset = @order.base_asset
    @order.quote_asset ||= @asset.platform.native_asset
  end

  def create
    @order = Order.new(order_params)
    @asset = @order.base_asset
    @order.user = current_user

    respond_to do |format|
      if @order.save
        @order.process!
        format.html { redirect_to orders_path, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @order = current_user.orders.find(params[:id])
    @order.cancel!

    respond_to do |format|
      format.html { redirect_to orders_path, notice: 'Order was successfully cancelled.' }
      format.json { render :show, status: :destroyed, location: @order }    
    end
  end

  private

  def order_params
    params.require(:order).permit(:base_asset_id, :quote_asset_id, :side, :kind, :quantity, :rate)
  end
end
