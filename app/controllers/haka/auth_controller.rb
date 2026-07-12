module Haka

  # Haka Authentication for a SAML Service Provider
  class AuthController < ApplicationController

    # Initiates a new SAML sign in request
    def new
      request = OneLogin::RubySaml::Authrequest.new
      # The IdP SSO URL is another host; load_defaults 8.1 turned on the
      # open-redirect protection (raise_on_open_redirects, Rails 7.0 default).
      redirect_to request.create(saml_settings), allow_other_host: true
    end

    # Receives the SAML assertion after Haka sign in
    def consume
      # params[:SAMLResponse] can be blank if GET route is accessed directly without actual authn.
      if params[:SAMLResponse].blank?
        redirect_to frontend_error_path("invalid_saml_response")
        return
      end

      response = OneLogin::RubySaml::Response.new(
        params[:SAMLResponse],
        settings: saml_settings,
        allowed_clock_drift: 5.seconds
      )

      unless response.is_valid?
        Rails.logger.error "Invalid SAML response: #{response.errors}"
        Rollbar.error "Invalid SAML response", errors: response.errors

        redirect_to frontend_error_path("invalid_saml_response")
        return
      end

      Rails.logger.debug "Reponse attributes: #{response.attributes.inspect}"
      person = Person.new(response.attributes.multi(Vaalit::Haka::HAKA_STUDENT_NUMBER_FIELD))

      unless person.valid?
        # Person details (student number) are logged only at debug level.
        Rails.logger.info "No voting right for person, failures: #{person.errors.attribute_names}"
        Rails.logger.debug "No voting right for person '#{person.inspect}'"
        Rollbar.info "No voting right present", failures: person.errors.attribute_names

        redirect_to frontend_error_path("no_voting_right")
        return
      end

      redirect_to frontend_signin_path(
        SessionToken.new(person.voter).ephemeral_jwt
      )
    end

    private
    begin

      def frontend_error_path(failure_key)
        "/#/sign-in-error?failure=#{failure_key}"
      end

      def frontend_signin_path(token)
        "/#/sign-in?token=#{token}"
      end

      def saml_settings
        settings = OneLogin::RubySaml::Settings.new

        # Require identity provider to (re)authenticate user also when a
        # previously authenticated session is still valid.
        settings.force_authn = true

        settings.idp_entity_id                  = Vaalit::Haka::SAML_IDP_ENTITY_ID
        settings.idp_sso_target_url             = Vaalit::Haka::SAML_IDP_SSO_TARGET_URL
        settings.idp_cert                       = Vaalit::Haka::SAML_IDP_CERT

        settings.assertion_consumer_service_url = Vaalit::Haka::SAML_ASSERTION_CONSUMER_SERVICE_URL
        settings.name_identifier_format         = Vaalit::Haka::SAML_NAME_IDENTIFIER_FORMAT

        settings.sp_entity_id                   = Vaalit::Haka::SAML_MY_ENTITY_ID
        settings.certificate                    = Vaalit::Haka::SAML_MY_CERT
        settings.private_key                    = Vaalit::Haka::SAML_MY_PRIVATE_KEY

        # Fingerprint can be used in local testing instead of a cert.
        # When SAML assertions are encrypted, an actual cert is required and
        # fingerprint can be left blank.
        if Vaalit::Haka::SAML_IDP_CERT_FINGERPRINT.present?
          settings.idp_cert_fingerprint         = Vaalit::Haka::SAML_IDP_CERT_FINGERPRINT
        end

        settings
      end

    end

  end
end
