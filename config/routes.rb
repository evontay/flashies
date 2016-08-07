Rails.application.routes.draw do
  devise_for :users
  resources :decks

  root "decks#index"
end
