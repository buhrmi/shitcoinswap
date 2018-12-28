class PagesController < ApplicationController
  skip_before_action :require_user
  
  def welcome
    return render 'assets/show' if @asset = current_brand_asset
    
    @featured_assets = Asset.where('featured_at IS NOT NULL').order('featured_at desc')
    @top_assets = Asset.with_24h_volume_cache(current_quote_asset.id).order('sum_trades desc').limit(3)
  end

  def show
    render params[:id]
  end
end
