require 'rails_helper'

RSpec.describe Api::V1::StudentsController, type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:user) { User.create(email: 'alice@example.com') }
  let(:student_attributes) do
    {
      name: 'Alice Doe',
      birthday: '07/03/1994',
      phone_number: 1199999999,
      cpf: 41564684881,
      gender: 'F',
      payment_method: payment_method
    }
  end

  shared_examples 'show response' do |payment_method, http_status|
    let(:payment_method) { payment_method }

    it { expect(response).to have_http_status(http_status) }
    it { expect(json['student']['name']).to eq(student_attributes[:name]) }
    it { expect(json['student']['birthday'].to_date.day).to eq(student_attributes[:birthday].to_date.day) }
    it { expect(json['student']['birthday'].to_date.month).to eq(student_attributes[:birthday].to_date.month) }
    it { expect(json['student']['birthday'].to_date.year).to eq(student_attributes[:birthday].to_date.year) }
    it { expect(json['student']['cpf']).to eq(student_attributes[:cpf]) }
    it { expect(json['student']['phone_number']).to eq(student_attributes[:phone_number]) }
    it { expect(json['student']['gender']).to eq(student_attributes[:gender]) }
  end

  shared_examples 'index response' do |payment_method|
    let(:payment_method) { payment_method }

    it { expect(response).to have_http_status(:ok) }
    it { expect(json['students'].count).to eq(1) }
    it { expect(json['students'].first['name']).to eq(student_attributes[:name]) }
    it { expect(json['students'].first['birthday'].to_date.day).to eq(student_attributes[:birthday].to_date.day) }
    it { expect(json['students'].first['birthday'].to_date.month).to eq(student_attributes[:birthday].to_date.month) }
    it { expect(json['students'].first['birthday'].to_date.year).to eq(student_attributes[:birthday].to_date.year) }
    it { expect(json['students'].first['cpf']).to eq(student_attributes[:cpf]) }
    it { expect(json['students'].first['phone_number']).to eq(student_attributes[:phone_number]) }
    it { expect(json['students'].first['gender']).to eq(student_attributes[:gender]) }
  end

  describe 'POST /create' do
    context 'success' do
      context 'invoice' do
        before do
          post api_v1_students_path,
            params: {
                student: student_attributes,
                access_token: user.access_token
              }
        end

        include_examples 'show response', 'invoice', :created
        it { expect(json['student']['payment_method']).to eq('Boleto') }
      end

      context 'card' do
        before do
          post api_v1_students_path,
            params: {
                student: student_attributes,
                access_token: user.access_token
              }
        end

        include_examples 'show response', 'card', :created
        it { expect(json['student']['payment_method']).to eq('Cartão de crédito') }
      end
    end

    context 'fail' do
      let(:payment_method) { 'card' }

      context 'empty values' do
        before do
          post api_v1_students_path,
            params: {
                student: { name: '' },
                access_token: user.access_token
              }
        end

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(json).to include('Nome não pode ficar em branco') }
        it { expect(json).to include('CPF não pode ficar em branco') }
        it { expect(json).to include('Gênero não pode ficar em branco') }
        it { expect(json).to include('Forma de pagamento não pode ficar em branco') }
      end

      context 'duplicated values' do
        before do
          Student.create(student_attributes)

          post api_v1_students_path,
            params: {
                student: student_attributes,
                access_token: user.access_token
              }
        end

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(json).to include('Nome já está em uso') }
        it { expect(json).to include('CPF já está em uso') }
      end

      context 'invalid values' do
        let(:student_attributes) do
          {
            name: 'Alice Doe',
            cpf: 'abc',
            gender: 'Azeitonas',
            payment_method: 'Picles'
          }
        end

        before do
          post api_v1_students_path,
            params: {
                student: student_attributes,
                access_token: user.access_token
              }
        end

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(json).to include("Gênero #{student_attributes[:gender]} inválido, valores válidos: M ou F") }
        it { expect(json).to include("Forma de pagamento #{student_attributes[:payment_method]} inválido, valores válidos: Cartão ou Boleto") }
        it { expect(json).to include("CPF #{student_attributes[:cpf]} não é um número") }
      end
    end
  end

  describe 'GET /index' do
    before do
      Student.create(student_attributes)

      get api_v1_students_path, params: { access_token: user.access_token }
    end

    context 'invoice' do
      include_examples 'index response', 'invoice'
      it { expect(json['students'].first['payment_method']).to eq('Boleto') }
    end

    context 'card' do
      include_examples 'index response', 'card'
      it { expect(json['students'].first['payment_method']).to eq('Cartão de crédito') }
    end
  end

  describe 'GET /show' do
    let(:student) { Student.create(student_attributes) }

    context 'success' do
      before do
        get api_v1_student_path(student), params: { access_token: user.access_token }
      end

      context 'invoice' do
        include_examples 'show response', 'invoice', :ok
        it { expect(json['student']['payment_method']).to eq('Boleto') }
      end

      context 'card' do
        include_examples 'show response', 'card', :ok
        it { expect(json['student']['payment_method']).to eq('Cartão de crédito') }
      end
    end

    context 'fail' do
      before do
        get api_v1_student_path(id: 123), params: { access_token: 'foobar123' }
      end

      it { expect(response).to have_http_status(:forbidden) }
      it { expect(json['errors']).to include('usuário não encontrado') }
    end
  end
end
