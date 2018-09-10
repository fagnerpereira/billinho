require 'rails_helper'

RSpec.describe Api::V1::InvoicesController, type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:user) { User.create(email: 'alice@example.com') }
  let(:student) do
    Student.create \
      name: 'Alice Doe',
      birthday: '07/03/1994',
      phone_number: 1199999999,
      cpf: 41564684881,
      gender: 'F',
      payment_method: 'invoice'
  end
  let(:institution) do
    user.institutions.create \
      name: 'FIAP',
      cnpj: 123456789,
      kind: 'university'
  end

  let(:registration) do
    institution.registrations.create \
      amount: 1000,
      bills_count: 5,
      bill_expiry_day: 7,
      course_name: 'Administração',
      student: student
  end

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
