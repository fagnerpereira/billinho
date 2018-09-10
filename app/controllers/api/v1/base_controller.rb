class Api::V1::BaseController < ApplicationController
  helper_method :current_user
  before_action :authenticate

  def warden
    request.env['warden']
  end

  def current_user
    warden.user(:api)
  end

  def authenticate
    return true if warden.authenticate(scope: :api)

    render_error(:forbidden, request.env['warden'].message)
  end

  def render_error(status, message)
    warden.custom_failure!

    render json: { errors: [I18n.t(message)] }, status: status
  end
end
