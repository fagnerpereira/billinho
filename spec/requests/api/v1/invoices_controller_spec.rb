require 'rails_helper'

RSpec.describe Api::V1::InvoicesController, type: :request do
  let(:json) { JSON.parse(response.body) }

  include_context 'registration'

  let(:invoice) do
    registration.invoices.create(expires_at: '10/10/2018', value: 200)
  end

  describe 'PATCH /pay' do
    let(:current_date) { Time.local(2018, 9, 7).to_date }

    before { Timecop.freeze(current_date) }
    after { Timecop.return }

    context 'success' do
      before do
        patch pay_api_v1_invoice_path(invoice),
          params: {
              access_token: user.access_token
            }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['invoice']['value']).to eq(registration.amount / registration.bills_count) }
      it { expect(json['invoice']['expires_at'].to_date.day).to eq(10) }
      it { expect(json['invoice']['expires_at'].to_date.month).to eq(10) }
      it { expect(json['invoice']['status']).to eq('Pago') }
    end

    context 'fail' do
      before do
        invoice.pay

        patch pay_api_v1_invoice_path(invoice),
          params: {
              access_token: user.access_token
            }
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(json).to include('Situação já consta como paga') }
    end
  end
end
