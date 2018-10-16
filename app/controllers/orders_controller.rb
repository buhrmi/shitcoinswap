class OrdersController < ApplicationController
  skip_before_action :require_user

  def index
    @orders = Order.open
  end
end
