class DecksController < ApplicationController
  before_action :find_deck, only: [:show, :edit, :update, :destroy]

  def index
    @user = User.where(username: params[:username])
    # @decks = Deck.all.order("created_at DESC")
    #@decks = Deck.where(user_id: @user.user_id) ||
    @decks = Deck.where(user_id: current_user)
  end

  def new
    @deck = current_user.decks.build
  end


  def create
    @deck = current_user.decks.build(deck_params)

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
