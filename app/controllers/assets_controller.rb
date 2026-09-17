class AssetsController < ApplicationController
  def index
    @assets = Asset.all
  end

  def show
  end

  def new
  end
end
