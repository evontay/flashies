Rails.application.routes.draw do
  resources :decks

  root "decks#index"
end
