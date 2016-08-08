Rails.application.routes.draw do
  devise_for :users
  root 'static#index'
  resources :decks do
    resources :cards
  end
end
