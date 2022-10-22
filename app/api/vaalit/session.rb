module Vaalit

  module Entities
    class SessionToken < Grape::Entity
      expose :jwt
      expose :elections,
        using: Entities::Election,
        if: lambda { |token, opts| RuntimeConfig.voting_active? }
      expose :voter, using: Entities::Voter
      expose :user,  using: Entities::User
    end
  end

  class Session < Grape::API
    before do
      begin
        authorize! :access, :sessions
      rescue CanCan::AccessDenied => exception
        error!(
          {
            message: "Unauthorized: #{exception.message}",
            key: ".session_creation_not_permitted"
          },
          :unauthorized)
      end
    end

    namespace :sessions do
      params do
        requires :token, type: String, desc: 'JWT token from session link'
      end
      desc 'Grant a new session JWT'
      post do
        processor = SignInTokenProcessor.new URI.decode_www_form_component(params[:token])

        if processor.valid? && processor.session_token.valid?
          present processor.session_token, with: Entities::SessionToken
        else
          error!("Invalid sign-in token", :forbidden)
        end
      end
    end
  end
end
