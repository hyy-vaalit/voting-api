module Vaalit
  module Export

    class ExportApi < Grape::API

      before do
        @current_user = current_service_user headers

        error!({ message: 'Unauthorized' }, :unauthorized) unless @current_user

        begin
          authorize! :access, :export
        rescue CanCan::AccessDenied => exception
          Rails.logger.info <<-MSG.squish
            AccessDenied to export_api;
            voting active: #{RuntimeConfig.voting_active?},
            elections active: #{RuntimeConfig.elections_active?}
          MSG
          error!({ message: "Unauthorized: #{exception.message}" }, :unauthorized)
        end

      end

      mount Export::Votes
    end

  end
end
