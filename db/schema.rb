# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_31_040324) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "scraper_records", force: :cascade do |t|
    t.string "site", null: false
    t.string "categoria"
    t.string "codigo", null: false
    t.string "titulo"
    t.string "localizacao"
    t.string "link"
    t.string "imagem"
    t.decimal "preco_brl", precision: 12, scale: 2
    t.integer "dormitorios"
    t.integer "suites"
    t.integer "vagas"
    t.decimal "area_m2", precision: 10, scale: 2
    t.decimal "condominio", precision: 12, scale: 2
    t.decimal "iptu", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "banheiros"
    t.integer "lavabos"
    t.decimal "area_privativa_m2", precision: 10, scale: 2
    t.string "mobiliacao"
    t.jsonb "amenities", default: []
    t.integer "vagas_min"
    t.integer "vagas_max"
    t.text "descricao"
    t.string "cidade"
    t.index ["amenities"], name: "index_scraper_records_on_amenities", using: :gin
    t.index ["categoria"], name: "index_scraper_records_on_categoria"
    t.index ["localizacao"], name: "index_scraper_records_on_localizacao"
    t.index ["preco_brl"], name: "index_scraper_records_on_preco_brl"
    t.index ["site", "cidade"], name: "index_scraper_records_on_site_and_cidade"
    t.index ["site", "codigo", "categoria"], name: "index_scraper_records_on_site_codigo_categoria", unique: true
  end
end
