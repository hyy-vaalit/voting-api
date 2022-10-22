# List routes:
#   rake routes
#   rake grape:routes
#
Rails.application.routes.draw do
  # Frontend's environment, see also: `frontend_config/frontend_environment.js.erb`
  get '/_environment.js', to: 'public#environment'

  # Grape API in app/api/
  mount Api => '/'

  # SAML Authentication from the Haka federation
  namespace :haka do
    get 'auth/new'
    get 'auth/consume'
    post 'auth/consume'
  end
end
