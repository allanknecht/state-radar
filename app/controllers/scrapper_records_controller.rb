# app/controllers/scraper_records_controller.rb
class ScrapperRecordsController < ApplicationController
  # GET /scraper_records
  def index
    scope = ScrapperRecord.all

    scope = scope.where(categoria: params[:category]) if params[:category].present?
    scope = scope.where("preco_brl >= ?", params[:min_price]) if params[:min_price].present?
    scope = scope.where("preco_brl <= ?", params[:max_price]) if params[:max_price].present?
    scope = scope.where("dormitorios >= ?", params[:min_bedrooms]) if params[:min_bedrooms].present?
    scope = scope.where("localizacao ILIKE ?", "%#{params[:q]}%") if params[:q].present?

    case params[:sort]
    when "price_asc" then scope = scope.order(preco_brl: :asc)
    when "price_desc" then scope = scope.order(preco_brl: :desc)
    end

    records = scope.page(params[:page]).per(params[:per] || 20)

    render json: {
      data: records.as_json(only: %i[
                              id site categoria codigo titulo localizacao link imagem
                              preco_brl dormitorios suites vagas area_m2 condominio iptu
                            ]),
      meta: {
        page: records.current_page,
        total_pages: records.total_pages,
        total_count: records.total_count,
        per: records.limit_value,
      },
    }
  end

  # GET /scraper_records/:id
  def show
    record = ScrapperRecord.find(params[:id])
    render json: record.as_json
  end
end
