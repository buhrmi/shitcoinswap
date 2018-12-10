class BrandingsController < ApplicationController
  before_action :set_branding, only: [:show, :edit, :update, :destroy]

  # GET /brandings
  # GET /brandings.json
  def index
    @brandings = Branding.all
  end

  # GET /brandings/1
  # GET /brandings/1.json
  def show
  end

  # GET /brandings/new
  def new
    @branding = Branding.new
  end

  # GET /brandings/1/edit
  def edit
  end

  # POST /brandings
  # POST /brandings.json
  def create
    @branding = Branding.new(branding_params)

    respond_to do |format|
      if @branding.save
        format.html { redirect_to @branding, notice: 'Branding was successfully created.' }
        format.json { render :show, status: :created, location: @branding }
      else
        format.html { render :new }
        format.json { render json: @branding.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /brandings/1
  # PATCH/PUT /brandings/1.json
  def update
    respond_to do |format|
      if @branding.update(branding_params)
        format.html { redirect_to @branding, notice: 'Branding was successfully updated.' }
        format.json { render :show, status: :ok, location: @branding }
      else
        format.html { render :edit }
        format.json { render json: @branding.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brandings/1
  # DELETE /brandings/1.json
  def destroy
    @branding.destroy
    respond_to do |format|
      format.html { redirect_to brandings_url, notice: 'Branding was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branding
      @branding = Branding.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def branding_params
      params.require(:branding).permit(:name, :domain, :options)
    end
end
