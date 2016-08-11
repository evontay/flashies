class CardsController < ApplicationController
  before_action :set_deck
  before_action :set_card, except:[:index, :create, :new]

  def index
    @cards = @deck.cards.all
    @can_edit = current_user.id == @user.id

    @deck = Deck.where(user_id: @user)
    @card = Card.new
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

  def edit
  end

  def update
    if @card.update(card_params)
      redirect_to @deck, notice: "Card was Successfully updated!"
    else
      render 'edit'
    end
  end

  def destroy
    @card.destroy
    redirect_to @deck
  end

  private


  def set_deck
    @deck = Deck.find(params[:deck_id])

    if current_user.id != @deck.user.id
      return redirect_to @deck
    end
  end

  def set_card
    @card = @deck.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:prompt_text, :prompt_image, :prompt_audio, :answer)
  end
end
