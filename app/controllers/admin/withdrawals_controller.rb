class Admin::WithdrawalsController < ApplicationController
  def index
    @withdrawals = Withdrawal.all
  end
end