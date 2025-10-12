class UpdateUniqueIndexScraperRecordsKeys < ActiveRecord::Migration[7.1]
  def change
    remove_index :scraper_records, [:site, :codigo], if_exists: true

    add_index :scraper_records, [:site, :codigo, :categoria],
              unique: true,
              name: "index_scraper_records_on_site_codigo_categoria"
  end
end
