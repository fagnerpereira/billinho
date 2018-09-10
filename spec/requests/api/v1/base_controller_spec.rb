require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :request do
  let(:user) { User.create(email: 'alice@example.com') }
  let(:json) { JSON.parse(response.body) }

  describe "GET /whoami" do
    context 'success' do
      before do
        get api_v1_whoami_path, params: { access_token: user.access_token }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(json['user']['email']).to include(user.email) }
    end

    context 'fail' do
      before do
        get api_v1_whoami_path, params: { access_token: 'foobar123' }
      end

      it { expect(response).to have_http_status(:forbidden) }
      it { expect(json['errors']).to include('usuário não encontrado') }
    end
  end
end
