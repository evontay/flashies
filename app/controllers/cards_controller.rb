class CardsController < ApplicationController
  before_action :set_deck
  before_action :set_card, except:[:index, :create, :new]

  def index
    @cards = @deck.cards.all
  end

  def new
    @card = @deck.cards.new
  end

  def create
    @card = @deck.cards.new(card_params)

    if @card.save
      redirect_to @deck, notice: "Successfully created new card"
    else
      render 'new'
    end
  end

  def show
  end

  private


  def set_deck
    @deck = Deck.find(params[:deck_id])
  end

  def set_card
    @card = @deck.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:prompt_text, :prompt_image, :prompt_audio, :answer)
  end
end
