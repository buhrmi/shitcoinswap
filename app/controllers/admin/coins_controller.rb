class Admin::CoinsController < ApplicationController
  def index
    @coins = Coin.all
  end
end