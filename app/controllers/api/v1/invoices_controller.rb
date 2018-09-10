class Api::V1::InvoicesController < Api::V1::BaseController
  before_action :set_registration, only: :index
  before_action :set_invoice, only: [:show, :update, :destroy, :pay]

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = @registration.invoices
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
  end

  # POST /invoices
  # POST /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      render :show, status: :created
    else
      render json: @invoice.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def pay
    if @invoice.pay
      render :show, status: :ok
    else
      render json: @invoice.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    if @invoice.update(invoice_params)
      render :show, status: :ok, location: @invoice
    else
      render json: @invoice.errors, status: :unprocessable_entity
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @invoice.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: [I18n.t('api.invoice.not_found')] }, status: :not_found
    end

    def set_registration
      @registration = current_user.registrations.find(params[:registration_id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: [I18n.t('api.registration.not_found')] }, status: :not_found
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:value, :expires_at, :status)
    end
end
