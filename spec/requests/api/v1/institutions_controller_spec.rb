require 'rails_helper'

RSpec.describe Api::V1::InstitutionsController, type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:user) { User.create(email: 'alice@example.com') }
  let(:institution_attributes) do
    {
      name: 'FIAP',
      cnpj: 123456789,
      kind: 'Universidade'
    }
  end

  describe 'POST /create' do
    context 'success' do
      before do
        post api_v1_institutions_path,
          params: {
              institution: institution_attributes,
              access_token: user.access_token
            }
      end

      it { expect(response).to have_http_status(:created) }
      it { expect(json['institution']['name']).to eq(institution_attributes[:name]) }
      it { expect(json['institution']['cnpj']).to eq(institution_attributes[:cnpj]) }
      it { expect(json['institution']['kind']).to eq(institution_attributes[:kind]) }
    end

    context 'fail' do
      context 'empty values' do
        before do
          post api_v1_institutions_path,
            params: {
                institution: { name: '' },
                access_token: user.access_token
              }
        end

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(json).to include('Nome não pode ficar em branco') }
        it { expect(json).to include('CNPJ não pode ficar em branco') }
        it { expect(json).to include('Tipo não pode ficar em branco') }
      end

      context 'duplicated values' do
        before do
          user.institutions.create(institution_attributes)

          post api_v1_institutions_path,
            params: {
                institution: institution_attributes,
                access_token: user.access_token
              }
        end

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(json).to include('Nome já está em uso') }
        it { expect(json).to include('CNPJ já está em uso') }
        it { expect(json).to include('Tipo já está em uso') }
      end

      context 'invalid values' do
        let(:institution_attributes) do
          {
            name: 'FIAP',
            cnpj: 'abc',
            kind: 'Azeitonas'
          }
        end

        before do
          post api_v1_institutions_path,
            params: {
                institution: institution_attributes,
                access_token: user.access_token
              }
        end

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(json).to include("Tipo #{institution_attributes[:kind]} inválido, valores válidos: Universidade, Escola ou Creche") }
        it { expect(json).to include("CNPJ #{institution_attributes[:cnpj]} não é um número") }
      end
    end
  end

  describe 'GET /index' do
    before do
      user.institutions.create(institution_attributes)

      get api_v1_institutions_path, params: { access_token: user.access_token }
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(json['institutions'].count).to eq(1) }
    it { expect(json['institutions'].first['name']).to eq(institution_attributes[:name]) }
    it { expect(json['institutions'].first['cnpj']).to eq(institution_attributes[:cnpj]) }
    it { expect(json['institutions'].first['kind']).to eq(institution_attributes[:kind]) }
  end

  describe 'GET /show' do
    let(:institution) { user.institutions.create(institution_attributes) }

    context 'success' do
      before do
        get api_v1_institution_path(institution), params: { access_token: user.access_token }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['institution']['name']).to eq(institution.name) }
      it { expect(json['institution']['cnpj']).to eq(institution.cnpj) }
      it { expect(json['institution']['kind']).to eq(institution.kind) }
    end

    context 'fail' do
      before do
        get api_v1_institution_path(id: 123), params: { access_token: 'foobar123' }
      end

      it { expect(response).to have_http_status(:forbidden) }
      it { expect(json['errors']).to include('usuários não encontrado') }
    end
  end
end
