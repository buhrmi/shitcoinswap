class AssetsController < ApplicationController
  skip_before_action :require_user

  def contract
    @name = params[:name]
    @symbol = params[:symbol]
    @decimals = params[:decimals].to_i
    @unit = 10 ** @decimals
    @initial_supply = params[:initial_supply].to_i * @unit
    @mintable = params[:mintable]
    @max_supply = params[:max_supply].to_i * @unit
    @parents = []
    if @mintable && @max_supply > 0
      @parents << "CappedToken(#{@max_supply})"
    elsif @mintable
      @parents << "MintableToken"
    else
      @parents << 'StandardToken'
    end
    if params[:pausable]
      @parents << 'PausableToken'
    end
    if params[:crowdsale] && @mintable
      @crowdsale = true
      @phases = params[:phases]
      @price = params[:price]
      @start_date = params[:start_date]
      @end_date = params[:end_date]
    end

    template = File.open(Rails.root.join('template.sol.erb'), 'rb', &:read)
    send_data ERB.new(template).result(binding), filename: @name.parameterize(separator: '_').camelcase + '.sol'  
  end

  def edit
    @asset = Asset.find(params[:id])
  end

  def new
    @asset = Asset.new
  end

  def index
    @assets = Asset.all
  end

  def show
    @asset = Asset.find(params[:id])
  end

  def update
    @asset = Asset.find(params[:id])
    return unless @asset.submitter == current_user || current_user.admin?
    @asset.update(update_params)
    redirect_to @asset, notice: 'Asset was successfully updated.'
  end

  def create
    @asset = Asset.new(asset_params)

    respond_to do |format|
      if @asset.save
        format.html { redirect_to @asset, notice: 'Asset was successfully created.' }
        format.json { render :show, status: :created, location: @asset }
      else
        format.html { render :new }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def update_params
    params.require(:asset).permit(:description)
  end

  def asset_params
    params.require(:asset).permit(:platform_id, :address)
  end

end