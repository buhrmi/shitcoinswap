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
    raise_not_found unless @asset.managable_by? current_user
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

  # TODO: move into airdrop model
  def airdrop
    asset = Asset.find params[:airdrop][:asset_id]
    raise_not_found unless asset.managable_by? current_user

    recipients = params[:airdrop][:amounts].lines.map(&:split)
    total_amount = 0
    recipients.each do |r| 
      raise "invalid amount" if r[1].to_f <= 0
      total_amount +=r [1].to_f
    end
    raise "wallet funds are not sufficient" if total_amount > asset.in_wallet

    for recipient in recipients
      user = User.find_or_create_by! email: recipient[0]
      adjustment = BalanceAdjustment.create!(user: user, asset: asset, amount: recipient[1].to_f, memo: params[:airdrop][:memo], change: current_user)
      UserMailer.with(user: user, adjustment: adjustment).airdrop.deliver_later
    end
    redirect_back fallback_location: root_url, notice: "Airdrop has been executed."
  end

  def update
    @asset = Asset.find(params[:id])
    raise_not_found unless @asset.managable_by? current_user
    
    @asset.update(update_params)
    redirect_to @asset, notice: 'Asset was successfully updated.'
  end

  def create
    @asset = Asset.new(asset_params)
    @asset.submitter = current_user if current_user

    respond_to do |format|
      if @asset.save
        format.html { redirect_to edit_asset_url(@asset), notice: 'Asset was successfully created.' }
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