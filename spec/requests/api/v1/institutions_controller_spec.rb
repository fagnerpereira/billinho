require 'rails_helper'

RSpec.describe Api::V1::InstitutionsController, type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:user) { User.create(email: 'alice@example.com') }
  let(:institution_attributes) do
    {
      name: 'FIAP',
      cnpj: 123456789,
      kind: kind
    }
  end

  shared_examples 'show response' do |kind, http_status|
    let(:kind) { kind }

    it { expect(response).to have_http_status(http_status) }
    it { expect(json['institution']['name']).to eq(institution_attributes[:name]) }
    it { expect(json['institution']['cnpj']).to eq(institution_attributes[:cnpj]) }
  end

  shared_examples 'index response' do |kind|
    let(:kind) { kind }

    it { expect(response).to have_http_status(:ok) }
    it { expect(json['institutions'].count).to eq(1) }
    it { expect(json['institutions'].first['name']).to eq(institution_attributes[:name]) }
    it { expect(json['institutions'].first['cnpj']).to eq(institution_attributes[:cnpj]) }
  end

  describe 'POST /create' do
    context 'success' do
      context 'university' do
        before do
          post api_v1_institutions_path,
            params: {
                institution: institution_attributes,
                access_token: user.access_token
              }
        end

        include_examples 'show response', 'university', :created
        it { expect(json['institution']['kind']).to eq('Universidade') }
      end

      context 'school' do
        before do
          post api_v1_institutions_path,
            params: {
                institution: institution_attributes,
                access_token: user.access_token
              }
        end

        include_examples 'show response', 'school', :created
        it { expect(json['institution']['kind']).to eq('Escola') }
      end

      context 'nursery' do
        before do
          post api_v1_institutions_path,
            params: {
                institution: institution_attributes,
                access_token: user.access_token
              }
        end

        include_examples 'show response', 'nursery', :created
        it { expect(json['institution']['kind']).to eq('Creche') }
      end
    end

    context 'fail' do
      let(:kind) { 'university' }

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

    context 'university' do
      include_examples 'index response', 'university'
      it { expect(json['institutions'].first['kind']).to eq('Universidade') }
    end

    context 'school' do
      include_examples 'index response', 'school'
      it { expect(json['institutions'].first['kind']).to eq('Escola') }
    end

    context 'nursery' do
      include_examples 'index response', 'nursery'
      it { expect(json['institutions'].first['kind']).to eq('Creche') }
    end
  end

  describe 'GET /show' do
    let(:institution) { user.institutions.create(institution_attributes) }

    context 'success' do
      before do
        get api_v1_institution_path(institution), params: { access_token: user.access_token }
      end

      context 'university' do
        include_examples 'show response', 'university', :ok
        it { expect(json['institution']['kind']).to eq('Universidade') }
      end

      context 'school' do
        include_examples 'show response', 'school', :ok
        it { expect(json['institution']['kind']).to eq('Escola') }
      end

      context 'nursery' do
        include_examples 'show response', 'nursery', :ok
        it { expect(json['institution']['kind']).to eq('Creche') }
      end
    end

    context 'fail' do
      before do
        get api_v1_institution_path(id: 123), params: { access_token: 'foobar123' }
      end

      it { expect(response).to have_http_status(:forbidden) }
      it { expect(json['errors']).to include('usuário não encontrado') }
    end
  end
end
