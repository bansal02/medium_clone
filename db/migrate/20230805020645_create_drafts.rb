class CreateDrafts < ActiveRecord::Migration[7.0]
  def change
    create_table :drafts do |t|
      t.string :title
      t.references :author, foreign_key: true
      t.references :topic, foreign_key: true
      t.json :states, default: []
      t.string :text
      t.timestamps
    end
  end
end
