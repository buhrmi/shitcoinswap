class PairsController < ApplicationController
  def index
    @pairs = Pair.all.as_json(Pair::JSON_OPTIONS)
  end

  # Either /assets/:id or /assets/:network/:contract.
  def show
    pair = Pair.find(params[:id])
    @pair = pair.as_json(Pair::JSON_OPTIONS)
  end

  def new
  end
end
