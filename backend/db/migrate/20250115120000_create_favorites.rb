class CreateFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :scraper_record, null: false, foreign_key: { on_delete: :cascade }, index: true

      t.timestamps
    end

    add_index :favorites, [:user_id, :scraper_record_id], unique: true
  end
end

