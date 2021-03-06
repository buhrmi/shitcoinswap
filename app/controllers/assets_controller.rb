class AssetsController < ApplicationController
  skip_before_action :require_user

  def contract
    @name = params[:name]
    @symbol = params[:symbol]
    @decimals = params[:decimals].to_i
    @unit = 10 ** @decimals
    @initial_supply = params[:initial_supply].to_i * @unit
    @mintable = params[:mintable]
    @erc223 = params[:erc223]
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
    send_data ERB.new(template).result(binding), filename: @name.gsub(/[^0-9A-Za-z]/, '') + '.sol'  
  end

  def edit
    @no_cache = true
    @asset = Asset.find(params[:id])
    raise_not_found unless @asset.managable_by? current_user
  end

  def new
    @asset = Asset.new
  end

  def index
    @assets = Asset.with_24h_volume_cache(current_quote_asset.id).order('sum_trades desc').page(params[:page])
  end

  def show
    @asset = Asset.find(params[:id])
  end

  def update
    @asset = Asset.find(params[:id])
    raise_not_found unless @asset.managable_by? current_user

    @asset.update(update_params)
    @asset.fetch_platform_data!
    @asset.save!
    redirect_to @asset, notice: 'Asset was successfully updated.'
  end

  def create
    @asset = Asset.new(asset_params)
    @asset.submitter = current_user if current_user

    respond_to do |format|
      if @asset.save
        format.html { redirect_to edit_asset_url(@asset), notice: 'Thank you. The Asset was listed successfully. Please provide further details.' }
        format.json { render :show, status: :created, location: @asset }
      else
        format.html { render :new }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def update_params
    params.require(:asset).permit(:description, :website, :logo, :background, :whitepaper_en, :domain, page_content: [:html])
  end

  def asset_params
    params.require(:asset).permit(:platform_id, :address)
  end

end