class CachedBalancesController < ApplicationController
  def index
    @cached_balances = current_user.cached_balances
  end  
end