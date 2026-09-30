Rails.application.routes.draw do
  # Autenticación del back-office (generador nativo de Rails 8)
  resource :session
  resources :passwords, param: :token

  # Back-office
  namespace :admin do
    root "dashboard#show"
    resources :users
    resources :households do
      resources :memberships, only: %i[ create destroy ]
    end
    resources :categories, except: :show
    resources :expenses
    resources :incomes, except: :show
    resources :budgets, except: :show
    resources :reminders, except: :show do
      post :notify, on: :member
    end
  end

  # API pública para el front-end (TP N° 2)
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post "signup", to: "registrations#create"
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"

      resource :profile, only: %i[ show update ]
      resource :summary, only: :show
      resources :categories, only: %i[ index create ]
      resources :households, only: %i[ index show create ] do
        get :summary, on: :member
        resources :memberships, only: %i[ create destroy ]
      end
      resources :expenses, except: %i[ new edit ]
      resources :incomes, except: %i[ new edit ]
      resources :budgets, only: %i[ index create ]
      resources :reminders, only: %i[ index create update ] do
        patch :pay, on: :member
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/admin")
end
