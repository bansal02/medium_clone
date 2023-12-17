class CreateLists < ActiveRecord::Migration[7.0]
  def change
    create_table :lists do |t|
      t.references :author, foreign_key: true
      t.string :name
      t.json :article_ids, default: []
      t.json :shared_with, default: []
      t.timestamps
    end
  end
end
