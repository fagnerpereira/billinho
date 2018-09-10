class Api::V1::InstitutionsController < Api::V1::BaseController
  before_action :set_institution, only: [:show, :update, :destroy]

  # GET /institutions
  # GET /institutions.json
  def index
    @institutions = current_user.institutions
  end

  # GET /institutions/1
  # GET /institutions/1.json
  def show
  end

  # POST /institutions
  # POST /institutions.json
  def create
    @institution = current_user.institutions.new(institution_params)

    if @institution.save
      render :show, status: :created
    else
      render json: @institution.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /institutions/1
  # PATCH/PUT /institutions/1.json
  def update
    if @institution.update(institution_params)
      render :show, status: :ok, location: @institution
    else
      render json: @institution.errors, status: :unprocessable_entity
    end
  end

  # DELETE /institutions/1
  # DELETE /institutions/1.json
  def destroy
    @institution.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_institution
      @institution = current_user.institutions.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def institution_params
      params.require(:institution).permit(:name, :cnpj, :kind)
    end
end
