class DecksController < ApplicationController
  before_action :find_deck, only: [:show, :edit, :update, :destroy]

  def index

    # @decks = Deck.all.order("created_at ASC")
    @decks = Deck.where(user_id: params[:username]) || Deck.where(user_id: current_user)

    if params[:username].present?
      @user = User.find_by(username: params[:username])
      return redirect_to root_path if @user.blank?
    else
      @user = current_user
    end

    if current_user.id == @user.id
      @can_edit = true
    else
      @can_edit = false
    end

    #@can_edit = current_user.id == @user.id
    @decks = Deck.where(user_id: @user)
    @deck = Deck.new

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
    if params[:username].present?
      @user = User.find_by(username: params[:username])
      return redirect_to root_path if @user.blank?

    else
      @user = current_user
    end

    @card = Card.new
    @can_edit = current_user.id == @user.id
  end

  def edit
    if current_user.id != @deck.user.id
      return redirect_to @deck
    end
  end

  def update
    if current_user.id != @deck.user.id
      return redirect_to @deck
    end

    if @deck.update(deck_params)
      redirect_to decks_path, notice: "Deck was Successfully updated!"
    else
      render 'edit'
    end
  end

  def destroy
    if current_user.id != @deck.user.id
      return redirect_to @deck
    end

    @deck.destroy
    redirect_to decks_path
  end

  private

  def deck_params
    params.require(:deck).permit(:title, :description, :isPrivate)
  end

  def find_deck
	  @deck = Deck.find(params[:id])
  end


end
