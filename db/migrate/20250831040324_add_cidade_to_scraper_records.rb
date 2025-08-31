class AddCidadeToScraperRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :scraper_records, :cidade, :string
    add_index :scraper_records, [:site, :cidade]
  end
end
