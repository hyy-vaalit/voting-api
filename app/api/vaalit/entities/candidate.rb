module Vaalit
  module Entities

    class Candidate < Grape::Entity
      expose :id
      expose :alliance_id
      expose :firstname
      expose :lastname
      expose :candidate_name,   :as => :name
      expose :candidate_number, :as => :number
    end

  end
end
