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

ActiveRecord::Schema[8.0].define(version: 2025_10_12_154257) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "scraper_record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scraper_record_id"], name: "index_favorites_on_scraper_record_id"
    t.index ["user_id", "scraper_record_id"], name: "index_favorites_on_user_id_and_scraper_record_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

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
    t.string "iptu_parcelas"
    t.string "condominio_parcelas"
    t.index ["amenities"], name: "index_scraper_records_on_amenities", using: :gin
    t.index ["categoria"], name: "index_scraper_records_on_categoria"
    t.index ["localizacao"], name: "index_scraper_records_on_localizacao"
    t.index ["preco_brl"], name: "index_scraper_records_on_preco_brl"
    t.index ["site", "codigo", "categoria"], name: "index_scraper_records_on_site_codigo_categoria", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "favorites", "scraper_records", on_delete: :cascade
  add_foreign_key "favorites", "users"
end
