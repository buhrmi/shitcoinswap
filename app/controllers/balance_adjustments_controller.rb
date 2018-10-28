class BalanceAdjustmentsController < ApplicationController
  before_action :require_user

  # GET /balance_adjustments
  # GET /balance_adjustments.json
  def index
    @balance_adjustments = current_user.balance_adjustments.page params[:page]
    @balance_adjustments = @balance_adjustments.where(asset: params[:asset_id]) if params[:asset_id]
  end

  private


    # Never trust parameters from the scary internet, only allow the white list through.
    def balance_adjustment_params
      params.require(:balance_adjustment).permit(:asset_id, :user_id, :memo, :amount)
    end
end
