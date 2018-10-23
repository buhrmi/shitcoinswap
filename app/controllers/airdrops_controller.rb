class AirdropsController < ApplicationController
  before_action :set_airdrop, only: [:show, :edit, :update, :destroy]


  # GET /airdrops/new
  def new
    @airdrop = Airdrop.new(airdrop_params)
  end

  # POST /airdrops
  # POST /airdrops.json
  def create
    @airdrop = Airdrop.new(airdrop_params)
    @airdrop.user = current_user

    respond_to do |format|
      if @airdrop.save
        @airdrop.execute!
        format.html { redirect_to @airdrop.asset, notice: 'Airdrop was successfully created.' }
        format.json { render :show, status: :created, location: @airdrop }
      else
        format.html { render :new }
        format.json { render json: @airdrop.errors, status: :unprocessable_entity }
      end
    end
  end

  # # DELETE /airdrops/1
  # # DELETE /airdrops/1.json
  # def destroy
  #   @airdrop.destroy
  #   respond_to do |format|
  #     format.html { redirect_to airdrops_url, notice: 'Airdrop was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_airdrop
      @airdrop = Airdrop.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def airdrop_params
      params.require(:airdrop).permit(:asset_id, :amounts, :memo)
    end
end
