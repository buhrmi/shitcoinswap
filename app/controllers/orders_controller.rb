class OrdersController < ApplicationController
  def index
    @orders = Order.open
  end
end
