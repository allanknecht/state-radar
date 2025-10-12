module Api
  module V1
    class ScraperRecordsController < BaseController
      before_action :authenticate_api_v1_user!

      def index
        scope = ScraperRecord.all

        scope = scope.where(categoria: params[:category]) if params[:category].present?
        scope = scope.where(site: params[:site]) if params[:site].present?
        scope = scope.where(codigo: params[:codigo]) if params[:codigo].present?

        min_price = decimal_param(:min_price)
        max_price = decimal_param(:max_price)
        min_bed = int_param(:min_bedrooms, min: 0)

        scope = scope.where("preco_brl >= ?", min_price) if min_price
        scope = scope.where("preco_brl <= ?", max_price) if max_price
        scope = scope.where("dormitorios >= ?", min_bed) if min_bed

        if (search = params[:search].to_s.strip).present?
          search = ActiveRecord::Base.sanitize_sql_like(search)
          scope = scope.where(
            "codigo ILIKE ? OR titulo ILIKE ? OR localizacao ILIKE ?",
            "%#{search}%", "%#{search}%", "%#{search}%"
          )
        end

        if (q = params[:q].to_s.strip).present?
          q = ActiveRecord::Base.sanitize_sql_like(q)
          scope = scope.where("localizacao ILIKE ?", "%#{q}%")
        end

        case params[:sort]
        when "price_asc" then scope = scope.order(preco_brl: :asc, id: :desc)
        when "price_desc" then scope = scope.order(preco_brl: :desc, id: :desc)
        else scope = scope.order(created_at: :desc, id: :desc)
        end

        page = int_param(:page, default: 1, min: 1)
        records = scope.page(page).per(20)

        render json: {
          data: records.map { |r| serialize_record(r) },
          meta: {
            page: records.current_page,
            total_pages: records.total_pages,
            total_count: records.total_count,
            per: records.limit_value,
          },
        }
      end

      def show
        record = ScraperRecord.find_by(id: params[:id])
        if record
          render json: { data: serialize_record(record) }
        else
          render json: { error: { code: "not_found", message: "Registro não encontrado" } }, status: :not_found
        end
      end

      def sites
        render json: { data: ScraperRecord::SITES }
      end

      def categories
        render json: { data: ScraperRecord::CATEGORIES }
      end

      def by_code
        records = ScraperRecord.where(codigo: params[:codigo])

        if records.any?
          render json: {
            data: records.map { |r| serialize_record(r) },
            meta: { count: records.count },
          }
        else
          render json: {
            error: {
              code: "not_found",
              message: "Nenhum imóvel encontrado com o código '#{params[:codigo]}'",
            },
          }, status: :not_found
        end
      end

      private

      def serialize_record(record)
        attrs = record.attributes.slice(
          "id", "site", "categoria", "codigo", "titulo", "localizacao", "link", "imagem",
          "preco_brl", "dormitorios", "suites", "vagas", "area_m2", "condominio", "iptu",
          "banheiros", "lavabos", "area_privativa_m2", "mobiliacao", "amenities", "descricao",
          "iptu_parcelas", "condominio_parcelas", "created_at", "updated_at"
        )
        %w[preco_brl condominio iptu area_m2 area_privativa_m2].each do |k|
          v = attrs[k]
          attrs[k] = v.nil? ? nil : v.to_f
        end

        attrs["preco_formatado"] = record.preco_formatado
        attrs["iptu_formatado"] = record.iptu_formatado
        attrs["condominio_formatado"] = record.condominio_formatado

        attrs
      end
    end
  end
end
