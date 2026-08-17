# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }
  
  # Devise routes for user management
  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new'
    get 'sign_up', to: 'devise/registrations#new'
    get 'sign_out', to: 'devise/sessions#destroy'
  end

  # ============ Health Check ============
  get "up" => "rails/health#show", as: :rails_health_check

  resources :categories do
    member do
      patch :toggle_active  # For activating/deactivating
    end
    collection do
      get :grouped         # For grouped view
      get :system          # For system categories only
      get :user_categories # For user's custom categories
    end
  end

  resources :category_groups do
    member do
      patch :update_position  # For drag & drop reordering
    end
  end

  resources :expenses do
    collection do
      get :report          # For reports
      get :dashboard       # For dashboard/stats
      get :filter          # For filtered views
    end
  end

  resource :profile, only: [:show, :edit, :update], controller: 'users/profiles'
end
