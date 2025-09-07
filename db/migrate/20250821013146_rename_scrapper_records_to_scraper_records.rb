class RenamescraperRecordsToScraperRecords < ActiveRecord::Migration[8.0]
  def change
    rename_table :scraper_records, :scraper_records
  end
end
