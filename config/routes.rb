Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'whoami' => 'base#whoami'

      resources :students, only: [:index, :create, :show]
      resources :institutions, only: [:index, :create, :show]
      resources :registrations, only: [:index, :create, :show] do
        resources :invoices, only: [:index]
      end
      resources :invoices do
        patch :pay, on: :member
      end
    end
  end
end
