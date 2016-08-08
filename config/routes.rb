Rails.application.routes.draw do
  devise_for :users
  resources :decks do
    resources :cards
  end
  root "decks#index"
end
