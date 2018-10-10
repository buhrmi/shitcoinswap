class BalanceAdjustmentsController < ApplicationController
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

  # GET /balance_adjustments/1/edit
  def edit
  end

  # POST /balance_adjustments
  # POST /balance_adjustments.json
  def create
    @balance_adjustment = BalanceAdjustment.new(balance_adjustment_params)

    respond_to do |format|
      if @balance_adjustment.save
        format.html { redirect_to @balance_adjustment, notice: 'Balance adjustment was successfully created.' }
        format.json { render :show, status: :created, location: @balance_adjustment }
      else
        format.html { render :new }
        format.json { render json: @balance_adjustment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /balance_adjustments/1
  # PATCH/PUT /balance_adjustments/1.json
  def update
    respond_to do |format|
      if @balance_adjustment.update(balance_adjustment_params)
        format.html { redirect_to @balance_adjustment, notice: 'Balance adjustment was successfully updated.' }
        format.json { render :show, status: :ok, location: @balance_adjustment }
      else
        format.html { render :edit }
        format.json { render json: @balance_adjustment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /balance_adjustments/1
  # DELETE /balance_adjustments/1.json
  def destroy
    @balance_adjustment.destroy
    respond_to do |format|
      format.html { redirect_to balance_adjustments_url, notice: 'Balance adjustment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_balance_adjustment
      @balance_adjustment = BalanceAdjustment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def balance_adjustment_params
      params.require(:balance_adjustment).permit(:coin_id, :user_id, :change_type, :change_id, :memo, :amount)
    end
end
