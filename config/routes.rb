Rails.application.routes.draw do
  devise_for :users
  root '/'
  resources :decks do
    resources :cards
  end
end
