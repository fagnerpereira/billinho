Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'whoami' => 'base#whoami'

      resources :students
      resources :institutions
      resources :registrations do
        resources :invoices
      end
    end
  end
end
