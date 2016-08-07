class AddUserIdToDecks < ActiveRecord::Migration[5.0]
  def change
    add_column :decks, :user_id, :integer
    add_index :decks, :user_id
  end
end
