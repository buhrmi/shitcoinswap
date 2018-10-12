class PagesController < ApplicationController
  before_action :require_user!, except: [:welcome]
  def balances
    # TODO: serve binance-compatible JSON format if user requests JSON
  end
end
