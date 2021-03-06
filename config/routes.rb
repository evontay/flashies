Rails.application.routes.draw do

  devise_for :users, :controllers => { registrations: 'registrations' }
  root 'static#index'

    resources :decks do
      resources :cards
    end

  get ":username" => "decks#index", as: 'user'
  get ":username/decks/:id" => "decks#show", as: 'user_decks'
end
