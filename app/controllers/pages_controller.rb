class PagesController < ApplicationController
  before_action :authorize, only: [:balances]

  def balances
    # TODO: serve binance-compatible JSON format if user requests JSON
  end
end
