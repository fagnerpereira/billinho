Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'whoami' => 'base#whoami'

      resources :students
      resources :registrations
      resources :institutions
    end
  end
end
