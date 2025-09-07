class CreatescraperRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :scraper_records do |t|
      t.string :site
      t.string :categoria
      t.string :codigo
      t.string :titulo
      t.string :localizacao
      t.string :link
      t.string :imagem
      t.decimal :preco_brl
      t.integer :dormitorios
      t.integer :suites
      t.integer :vagas
      t.decimal :area_m2
      t.decimal :condominio
      t.decimal :iptu

      t.timestamps
    end
  end
end
