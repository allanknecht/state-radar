namespace :db do
  desc "Clean all records and indexes from database"
  task clean_all: :environment do
    puts "🧹 Starting database cleanup..."

    # Disable foreign key checks temporarily
    ActiveRecord::Base.connection.execute("SET session_replication_role = replica;")

    begin
      # Get all tables
      tables = ActiveRecord::Base.connection.tables
      puts "📋 Found #{tables.length} tables: #{tables.join(", ")}"

      # Drop all indexes first
      puts "🗑️  Dropping all indexes..."
      tables.each do |table|
        indexes = ActiveRecord::Base.connection.indexes(table)
        indexes.each do |index|
          next if index.name == "PRIMARY" # Skip primary key indexes
          begin
            ActiveRecord::Base.connection.remove_index(table, name: index.name)
            puts "   ✓ Dropped index: #{index.name} from #{table}"
          rescue => e
            puts "   ⚠️  Could not drop index #{index.name} from #{table}: #{e.message}"
          end
        end
      end

      # Truncate all tables (this removes all data)
      puts "🗑️  Truncating all tables..."
      tables.each do |table|
        begin
          ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE;")
          puts "   ✓ Truncated table: #{table}"
        rescue => e
          puts "   ⚠️  Could not truncate #{table}: #{e.message}"
        end
      end

      # Recreate indexes from schema
      puts "🔧 Recreating indexes from schema..."
      ActiveRecord::Base.connection.execute("SET session_replication_role = DEFAULT;")

      # Load schema to recreate indexes
      ActiveRecord::Schema.define do
        # Recreate indexes for users table
        add_index "users", ["email"], name: "index_users_on_email", unique: true
        add_index "users", ["jti"], name: "index_users_on_jti"
        add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

        # Recreate indexes for scraper_records table
        add_index "scraper_records", ["amenities"], name: "index_scraper_records_on_amenities", using: :gin
        add_index "scraper_records", ["categoria"], name: "index_scraper_records_on_categoria"
        add_index "scraper_records", ["localizacao"], name: "index_scraper_records_on_localizacao"
        add_index "scraper_records", ["preco_brl"], name: "index_scraper_records_on_preco_brl"
        add_index "scraper_records", ["site", "codigo", "categoria"], name: "index_scraper_records_on_site_codigo_categoria", unique: true

        # Recreate indexes for jwt_denylists table
        add_index "jwt_denylists", ["jti"], name: "index_jwt_denylists_on_jti"
      end

      puts "✅ Database cleanup completed successfully!"
      puts "📊 Current table status:"
      tables.each do |table|
        count = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{table}").first["count"]
        puts "   #{table}: #{count} records"
      end
    rescue => e
      puts "❌ Error during cleanup: #{e.message}"
      puts e.backtrace.join("\n")
      raise e
    ensure
      # Re-enable foreign key checks
      ActiveRecord::Base.connection.execute("SET session_replication_role = DEFAULT;")
    end
  end

  desc "Clean only data (keep indexes)"
  task clean_data: :environment do
    puts "🧹 Starting data cleanup (keeping indexes)..."

    begin
      # Get all tables
      tables = ActiveRecord::Base.connection.tables
      puts "📋 Found #{tables.length} tables: #{tables.join(", ")}"

      # Truncate all tables (this removes all data but keeps structure)
      puts "🗑️  Truncating all tables..."
      tables.each do |table|
        begin
          ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE;")
          puts "   ✓ Truncated table: #{table}"
        rescue => e
          puts "   ⚠️  Could not truncate #{table}: #{e.message}"
        end
      end

      puts "✅ Data cleanup completed successfully!"
      puts "📊 Current table status:"
      tables.each do |table|
        count = ActiveRecord::Base.connection.execute("SELECT COUNT(*) FROM #{table}").first["count"]
        puts "   #{table}: #{count} records"
      end
    rescue => e
      puts "❌ Error during data cleanup: #{e.message}"
      puts e.backtrace.join("\n")
      raise e
    end
  end
end

