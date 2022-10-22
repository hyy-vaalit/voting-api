class PublicController < ApplicationController

  # Environment for the Frontend.
  # Further details in:
  #   1) API `frontend_config/frontend_environment.js.erb`
  #   2) Frontend development env: `app/scripts/_environment.js`
  def environment
    render template: "frontend_config/frontend_environment"
  end
end
