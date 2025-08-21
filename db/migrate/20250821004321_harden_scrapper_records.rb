class HardenScrapperRecords < ActiveRecord::Migration[8.0]
  def change
    change_column :scrapper_records, :preco_brl, :decimal, precision: 12, scale: 2
    change_column :scrapper_records, :condominio, :decimal, precision: 12, scale: 2
    change_column :scrapper_records, :iptu, :decimal, precision: 12, scale: 2
    change_column :scrapper_records, :area_m2, :decimal, precision: 10, scale: 2

    change_column_null :scrapper_records, :site, false
    change_column_null :scrapper_records, :codigo, false

    add_index :scrapper_records, [:site, :codigo], unique: true
    add_index :scrapper_records, :categoria
    add_index :scrapper_records, :preco_brl
    add_index :scrapper_records, :localizacao
  end
end
