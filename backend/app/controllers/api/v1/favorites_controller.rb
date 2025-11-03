module Api
  module V1
    class FavoritesController < BaseController
      before_action :authenticate_api_v1_user!

      def index
        favorites = current_user.favorites
                                 .includes(:scraper_record)
                                 .order(created_at: :desc)

        render json: {
          data: favorites.map { |fav| serialize_favorite(fav) },
        }
      end

      def create
        scraper_record = ScraperRecord.find(params[:scraper_record_id])

        favorite = current_user.favorites.find_or_initialize_by(
          scraper_record: scraper_record
        )

        if favorite.persisted?
          render json: { error: { code: "already_favorited", message: "Imóvel já está nos favoritos" } },
                 status: :unprocessable_entity
        elsif favorite.save
          render json: { data: serialize_favorite(favorite) }, status: :created
        else
          render json: { error: { code: "validation_error", message: favorite.errors.full_messages.join(", ") } },
                 status: :unprocessable_entity
        end
      end

      def destroy
        scraper_record_id = params[:scraper_record_id] || params[:id]
        favorite = current_user.favorites.find_by(scraper_record_id: scraper_record_id)

        if favorite.nil?
          render json: { error: { code: "not_found", message: "Favorito não encontrado" } },
                 status: :not_found
        else
          favorite.destroy
          head :no_content
        end
      end

      private

      def serialize_favorite(favorite)
        record = favorite.scraper_record
        {
          id: favorite.id,
          scraper_record_id: record.id,
          created_at: favorite.created_at,
          scraper_record: serialize_record(record),
        }
      end

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

