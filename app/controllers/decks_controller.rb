class DecksController < ApplicationController
  def index
  end

  def new
    @deck = Deck.new
  end


  def create
    @deck = Deck.new(deck_params)
  end

  private

  def deck_params
    params.require(:deck).permit(:title, :description, :isPrivate)
  end
end
