require 'rails_helper'

RSpec.describe Api::V1::RegistrationsController, type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:user) { User.create(email: 'alice@example.com') }
  let(:student) do
    Student.create \
      name: 'Alice Doe',
      birthday: '07/03/1994',
      phone_number: 1199999999,
      cpf: 41564684881,
      gender: 'F',
      payment_method: 'Boleto'
  end
  let(:institution) do
    user.institutions.create \
      name: 'FIAP',
      cnpj: 123456789,
      kind: 'Universidade'
  end
  let(:registration_attributes) do
    {
      amount: 1000,
      bills_count: 5,
      bill_expiry_day: 7,
      course_name: 'Administração',
      institution_id: institution.id,
      student_id: student.id
    }
  end

  describe 'POST /create' do
    context 'success' do
      before do
        post api_v1_registrations_path,
          params: {
              registration: registration_attributes,
              access_token: user.access_token
            }
      end

      it { expect(response).to have_http_status(:created) }
      it { expect(json['registration']['amount']).to eq(registration_attributes[:amount]) }
      it { expect(json['registration']['bills_count']).to eq(registration_attributes[:bills_count]) }
      it { expect(json['registration']['bill_expiry_day']).to eq(registration_attributes[:bill_expiry_day]) }
      it { expect(json['registration']['course_name']).to eq(registration_attributes[:course_name]) }
      it { expect(json['registration']['institution_id']).to eq(registration_attributes[:institution_id]) }
      it { expect(json['registration']['student_id']).to eq(registration_attributes[:student_id]) }
    end

    context 'fail' do
      context 'empty values' do
        before do
          post api_v1_registrations_path,
            params: {
                registration: { amount: '' },
                access_token: user.access_token
              }
        end

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(json).to include('Valor total não pode ficar em branco') }
        it { expect(json).to include('Quantidade de faturas não pode ficar em branco') }
        it { expect(json).to include('Dia de vencimento não pode ficar em branco') }
        it { expect(json).to include('Nome do curso não pode ficar em branco') }
      end

      context 'invalid values' do
        it 'amount must be greater than 0' do
          registration_attributes[:amount] = 0

          post api_v1_registrations_path,
            params: {
                registration: registration_attributes,
                access_token: user.access_token
              }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json).to include('Valor total deve ser maior que 0')
        end

        it 'amount must be greater than 0' do
          registration_attributes[:bills_count] = 0

          post api_v1_registrations_path,
            params: {
                registration: registration_attributes,
                access_token: user.access_token
              }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json).to include('Quantidade de faturas deve ser maior que 0')
        end

        it 'amount must be greater than 0' do
          registration_attributes[:bill_expiry_day] = 0

          post api_v1_registrations_path,
            params: {
                registration: registration_attributes,
                access_token: user.access_token
              }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json).to include('Dia de vencimento deve ser maior que 0')
        end

        it 'amount must be greater than 0' do
          registration_attributes[:bill_expiry_day] = 31

          post api_v1_registrations_path,
            params: {
                registration: registration_attributes,
                access_token: user.access_token
              }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json).to include('Dia de vencimento deve ser menor que 31')
        end
      end
    end
  end

  describe 'GET /show' do
    let(:registration) { Registration.create(registration_attributes) }

    context 'success' do
      before do
        get api_v1_registration_path(registration), params: { access_token: user.access_token }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['registration']['amount']).to eq(registration.amount) }
      it { expect(json['registration']['bills_count']).to eq(registration.bills_count) }
      it { expect(json['registration']['bill_expiry_day']).to eq(registration.bill_expiry_day) }
      it { expect(json['registration']['course_name']).to eq(registration.course_name) }
      it { expect(json['registration']['institution_id']).to eq(registration.institution_id) }
      it { expect(json['registration']['student_id']).to eq(registration.student_id) }
    end

    context 'fail' do
      before do
        get api_v1_registration_path(id: 123), params: { access_token: 'foobar123' }
      end

      it { expect(response).to have_http_status(:forbidden) }
      it { expect(json['errors']).to include('usuários não encontrado') }
    end
  end

  describe 'GET /index' do
    before do
      Registration.create(registration_attributes)

      get api_v1_registrations_path, params: { access_token: user.access_token }
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(json['registrations'].count).to eq(1) }
    it { expect(json['registrations'].first['amount']).to eq(registration_attributes[:amount]) }
    it { expect(json['registrations'].first['bills_count']).to eq(registration_attributes[:bills_count]) }
    it { expect(json['registrations'].first['bill_expiry_day']).to eq(registration_attributes[:bill_expiry_day]) }
    it { expect(json['registrations'].first['course_name']).to eq(registration_attributes[:course_name]) }
    it { expect(json['registrations'].first['institution_id']).to eq(registration_attributes[:institution_id]) }
    it { expect(json['registrations'].first['student_id']).to eq(registration_attributes[:student_id]) }
  end

  describe 'GET /invoices' do
    let(:registration) { Registration.create(registration_attributes) }

    before do
      registration.generate_invoices
      get api_v1_registration_invoices_path(registration), params: { access_token: user.access_token }
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(json['invoices'].count).to eq(1) }
    it { expect(json['invoices'].first['value']).to eq(registration.amount / registration.bills_count) }
    it { expect(json['invoices'].first['expires_at'].day).to eq(registration.next_expiration_day) }
    it { expect(json['invoices'].first['expires_at'].month).to eq(registration.next_expiration_month) }
    it { expect(json['invoices'].first['status']).to eq('open') }
  end
end
