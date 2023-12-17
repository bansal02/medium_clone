class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :name, default: "FullName"
      t.string :username
      t.string :interest, default: "adventure"
      t.string :speciality, default: "adventure"
      t.json :article_ids, default: []
      t.json :following_ids, default: []
      t.json :saved_ids, default: []
      t.integer :views, default: 0
      t.json :shared_lists, default: []
      t.timestamps
    end
  end
end
