class PagesController < ApplicationController
  skip_before_action :require_user
  
  def welcome
    @featured_assets = Asset.where('featured_at IS NOT NULL').order('featured_at desc')
  end

  def show
    render params[:id]
  end
end
