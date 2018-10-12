class Admin::WithdrawalsController < ApplicationController
  before_action :require_user!
  def index
    @withdrawals = Withdrawal.all
  end
end
