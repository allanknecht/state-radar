module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_api_v1_user!
      respond_to :json

      rescue_from ActiveRecord::RecordNotFound do |e|
        render_error(:not_found, "not_found", e.message)
      end

      rescue_from ActionController::ParameterMissing do |e|
        render_error(:unprocessable_entity, "param_missing", e.message)
      end

      private

      def current_user
        current_api_v1_user
      end

      def render_ok(data:, status: :ok, meta: nil)
        payload = { data: data }
        payload[:meta] = meta if meta
        render json: payload, status: status
      end

      def render_error(http_status, code, message, details: nil)
        render json: { error: { code: code, message: message, details: details } },
               status: http_status
      end

      def int_param(name, default: nil, min: nil, max: nil)
        return default unless params[name].present?
        v = params[name].to_i
        v = [v, min].max if min
        v = [v, max].min if max
        v
      end

      def decimal_param(name)
        return nil unless params[name].present?
        BigDecimal(params[name].to_s) rescue nil
      end
    end
  end
end
