Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  resources :books
  resources :users, only: %i[index show]
  root to: 'books#index'
end
