class Api < Grape::API
  prefix 'api'
  format :json

  helpers Vaalit::JwtHelpers

  helpers do
    # Change in Cancancan >= 2.1.x
    # Including CanCan::ControllerAdditions will try to call method "class_attribute" which
    # does not exist in this module. That call is only for initializing a "_cancan_skipper"
    # that allows easy usage of "skip_load_resource" and "skip_authorize_resource".
    # Since we don't use these, just catch the call for "class_attribute(_cancan_skipper)"
    # and do nothing.
    #
    # Before updating the cancancan gem, compare the current implementation and verify that
    # class_attribute is not used for something else (or whether it's removed altogether).
    # https://github.com/CanCanCommunity/cancancan/blob/3.1.0/lib/cancan/controller_additions.rb#L298
    def self.class_attribute(attr_from_controller_additions); end
    include CanCan::ControllerAdditions

    # Monkey patch to use @current_user
    def current_ability
      @current_ability ||= ::Ability.new(@current_user)
    end
  end

  mount Vaalit::Edari::EdariApi # Authorized
  mount Vaalit::Export::ExportApi # Authorized
  mount Vaalit::Voters::VotersApi # Authorized
  mount Vaalit::Stats::StatsApi # Authorized

  mount Vaalit::Pling   # Public
  mount Vaalit::Session # Public
  mount Vaalit::Public::PublicApi
end
