class WithdrawalsController < ApplicationController
  before_action :set_withdrawal, only: [:show, :edit, :update, :destroy]

  # GET /withdrawals
  # GET /withdrawals.json
  def index
    @withdrawals = Withdrawal.all
  end

  # GET /withdrawals/1
  # GET /withdrawals/1.json
  def show
  end

  # GET /withdrawals/new
  def new
    @withdrawal = Withdrawal.new
  end

  # GET /withdrawals/1/edit
  def edit
  end

  # POST /withdrawals
  # POST /withdrawals.json
  def create
    @withdrawal = Withdrawal.new(withdrawal_params)

    respond_to do |format|
      if @withdrawal.save
        format.html { redirect_to @withdrawal, notice: 'Withdrawal was successfully created.' }
        format.json { render :show, status: :created, location: @withdrawal }
      else
        format.html { render :new }
        format.json { render json: @withdrawal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /withdrawals/1
  # PATCH/PUT /withdrawals/1.json
  def update
    respond_to do |format|
      if @withdrawal.update(withdrawal_params)
        format.html { redirect_to @withdrawal, notice: 'Withdrawal was successfully updated.' }
        format.json { render :show, status: :ok, location: @withdrawal }
      else
        format.html { render :edit }
        format.json { render json: @withdrawal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /withdrawals/1
  # DELETE /withdrawals/1.json
  def destroy
    @withdrawal.destroy
    respond_to do |format|
      format.html { redirect_to withdrawals_url, notice: 'Withdrawal was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_withdrawal
      @withdrawal = Withdrawal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def withdrawal_params
      params.require(:withdrawal).permit(:symbol, :user_id, :receiver_address, :transaction_id, :submitted_at, :amount, :status, :tries, :error, :error_at, :signed_transaction)
    end
end
