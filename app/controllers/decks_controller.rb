class DecksController < ApplicationController
  before_action :find_deck, only: [:show, :edit, :update, :destroy]

  def index
    @decks = Deck.all.order("created_at DESC")
  end

  def new
    @deck = Deck.new
  end


  def create
    @deck = Deck.new(deck_params)

    if @deck.save
      redirect_to @deck, notice: "Successfully created new Deck"
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @deck.update(deck_params)
      redirect_to @deck, notice: "Deck was Successfully updated!"
    else
      render 'edit'
    end
  end

  def destroy
    @deck.destroy
    redirect_to root_path
  end

  private

  def deck_params
    params.require(:deck).permit(:title, :description, :isPrivate)
  end

  def find_deck
	  @deck = Deck.find(params[:id])
  end

end
