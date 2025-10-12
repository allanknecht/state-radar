class AddMoreCardFieldsToScraperRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :scraper_records, :banheiros, :integer
    add_column :scraper_records, :lavabos, :integer
    add_column :scraper_records, :area_privativa_m2, :decimal, precision: 10, scale: 2
    add_column :scraper_records, :mobiliacao, :string
    add_column :scraper_records, :amenities, :jsonb, default: []
    add_column :scraper_records, :vagas_min, :integer
    add_column :scraper_records, :vagas_max, :integer
    add_column :scraper_records, :descricao, :text

    add_index :scraper_records, :amenities, using: :gin
  end
end
