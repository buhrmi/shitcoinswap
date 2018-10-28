class BalanceAdjustmentsController < ApplicationController
  before_action :require_user

  def index
    @balance_adjustments = current_user.balance_adjustments.page params[:page]
    if params[:asset_id]
      @balance_adjustments = @balance_adjustments.where(asset: params[:asset_id])
      @asset = Asset.find(params[:asset_id])
    end
  end

  private


    # Never trust parameters from the scary internet, only allow the white list through.
    def balance_adjustment_params
      params.require(:balance_adjustment).permit(:asset_id, :user_id, :memo, :amount)
    end
end
