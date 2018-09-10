Rails.application.config.middleware.use Warden::Manager do |config|
  config.scope_defaults :api, strategies: [:access_token], store: false
end

Warden::Strategies.add(:access_token) do
  def valid?
    params['access_token']
  end

  def authenticate!
    user = User.find_by(access_token: params['access_token'])

    return fail! 'api.unauthorized' unless user

    success! user
  end
end
