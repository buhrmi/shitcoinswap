class PagesController < ApplicationController
  # skip_before_action :require_user, only: [:welcome]

  def balances
    # TODO: serve binance-compatible JSON format if user requests JSON
  end
end
