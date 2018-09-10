class Api::V1::RegistrationsController < Api::V1::BaseController
  before_action :set_registration, only: [:show, :update, :destroy]

  # GET /registrations
  # GET /registrations.json
  def index
    @registrations = current_user.registrations
  end

  # GET /registrations/1
  # GET /registrations/1.json
  def show
  end

  # POST /registrations
  # POST /registrations.json
  def create
    @registration = current_user.registrations.new(registration_params)

    if @registration.save
      @registration.generate_invoices

      render :show, status: :created
    else
      render json: @registration.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /registrations/1
  # PATCH/PUT /registrations/1.json
  def update
    if @registration.update(registration_params)
      render :show, status: :ok, location: @registration
    else
      render json: @registration.errors, status: :unprocessable_entity
    end
  end

  # DELETE /registrations/1
  # DELETE /registrations/1.json
  def destroy
    @registration.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_registration
      @registration = current_user.registrations.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def registration_params
      params.require(:registration).permit(:amount, :bills_count, :bill_expiry_day, :course_name, :institution_id, :student_id)
    end
end
