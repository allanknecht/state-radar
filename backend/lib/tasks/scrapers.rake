# lib/tasks/scrapers.rake
namespace :scrapers do
  desc "Run all property scrapers"
  task all: :environment do
    PropertyScraperJob.perform_now(:all)
  end

  desc "Run MWS scraper"
  task mws: :environment do
    PropertyScraperJob.perform_now(:mws)
  end

  desc "Run Simao scraper"
  task simao: :environment do
    PropertyScraperJob.perform_now(:simao)
  end

  desc "Run Solar scraper"
  task solar: :environment do
    PropertyScraperJob.perform_now(:solar)
  end

  desc "Queue all scrapers as background jobs"
  task queue_all: :environment do
    PropertyScraperJob.perform_later(:mws)
    PropertyScraperJob.perform_later(:simao)
    PropertyScraperJob.perform_later(:solar)
    puts "Queued scraper jobs for all sites"
  end

  desc "Show scraper statistics"
  task stats: :environment do
    puts "\n=== Scraper Statistics ==="

    ScraperRecord.group(:site).count.each do |site, count|
      puts "#{site.upcase}: #{count} records"
    end

    puts "\nBy Category:"
    ScraperRecord.group(:site, :categoria).count.each do |(site, categoria), count|
      puts "  #{site} - #{categoria}: #{count}"
    end

    puts "\nLast updated:"
    ScraperRecord.group(:site).maximum(:updated_at).each do |site, last_update|
      puts "  #{site}: #{last_update || "Never"}"
    end
  end

  desc "Clean old records (older than 30 days)"
  task clean_old: :environment do
    deleted = ScraperRecord.where("updated_at < ?", 30.days.ago).delete_all
    puts "Deleted #{deleted} old records"
  end
end
