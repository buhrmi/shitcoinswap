class Admin::BalanceAdjustmentsController < ApplicationController
  before_action :require_user!
  before_action :set_balance_adjustment, only: [:show, :edit, :update, :destroy]

  # GET /balance_adjustments
  # GET /balance_adjustments.json
  def index
    @balance_adjustments = BalanceAdjustment.all
  end

  # GET /balance_adjustments/1
  # GET /balance_adjustments/1.json
  def show
  end

  # GET /balance_adjustments/new
  def new
    @balance_adjustment = BalanceAdjustment.new
  end


  # POST /balance_adjustments
  # POST /balance_adjustments.json
  def create
    @balance_adjustment = BalanceAdjustment.new(balance_adjustment_params)

    # XXX: ensure the user has the right to adjustment balance
    @balance_adjustment.change = current_user

    respond_to do |format|
      if @balance_adjustment.save
        format.html { redirect_to [:admin, @balance_adjustment], notice: 'Balance adjustment was successfully created.' }
        format.json { render :show, status: :created, location: @balance_adjustment }
      else
        format.html { render :new }
        format.json { render json: @balance_adjustment.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_balance_adjustment
    @balance_adjustment = BalanceAdjustment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def balance_adjustment_params
    params.require(:balance_adjustment).permit(:coin_id, :user_id, :memo, :amount)
  end
end
