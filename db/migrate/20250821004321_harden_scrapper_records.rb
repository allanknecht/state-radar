class HardenscraperRecords < ActiveRecord::Migration[8.0]
  def change
    change_column :scraper_records, :preco_brl, :decimal, precision: 12, scale: 2
    change_column :scraper_records, :condominio, :decimal, precision: 12, scale: 2
    change_column :scraper_records, :iptu, :decimal, precision: 12, scale: 2
    change_column :scraper_records, :area_m2, :decimal, precision: 10, scale: 2

    change_column_null :scraper_records, :site, false
    change_column_null :scraper_records, :codigo, false

    add_index :scraper_records, [:site, :codigo], unique: true
    add_index :scraper_records, :categoria
    add_index :scraper_records, :preco_brl
    add_index :scraper_records, :localizacao
  end
end
