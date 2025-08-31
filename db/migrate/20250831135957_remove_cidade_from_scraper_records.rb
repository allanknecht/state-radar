class RemoveCidadeFromScraperRecords < ActiveRecord::Migration[8.0]
  def change
    remove_column :scraper_records, :cidade, :string
  end
end
