class PairsController < ApplicationController
  def index
    @pairs = Pair.all.as_json(Pair::JSON_OPTIONS)
  end

  def show
    pair = Pair.find(params[:id])
    @pair = pair.as_json(Pair::JSON_OPTIONS)
  end

  def new
  end
end
