class AddUsernameToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :username, :string, default: "", null: false, unique: true
  end
end
