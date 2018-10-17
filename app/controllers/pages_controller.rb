class PagesController < ApplicationController
  skip_before_action :require_user, only: [:welcome, :app]

  def balances
    # TODO: serve binance-compatible JSON format if user requests JSON
  end
end
