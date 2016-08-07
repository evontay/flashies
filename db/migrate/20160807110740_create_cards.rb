class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.text :prompt_text
      t.string :prompt_image
      t.string :prompt_audio
      t.text :answer

      t.timestamps
    end
  end
end
