class Api::V1::BaseController < ApplicationController
  before_action :set_user

  def set_user
    @user = User.find_by!(access_token: params[:access_token])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['usuários não encontrado'] }, status: :forbidden
  end
end
