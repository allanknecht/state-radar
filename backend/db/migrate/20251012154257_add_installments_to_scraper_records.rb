class AddInstallmentsToScraperRecords < ActiveRecord::Migration[8.0]
  def change
    add_column :scraper_records, :iptu_parcelas, :string
    add_column :scraper_records, :condominio_parcelas, :string
  end
end
