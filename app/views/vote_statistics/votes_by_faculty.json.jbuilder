json.name "Äänestäneiden lukumäärä tiedekunnittain"
json.year Time.now.year
json.created_at Time.now.localtime

json.children do
  json.faculties do
    json.array! stats do |faculty|
      json.name faculty["name"]
      json.voter_count faculty["voter_count"]
      if RuntimeConfig.elections_active?
        json.vote_count 0
      else
        json.vote_count faculty["vote_count"]
      end
      json.percentage faculty["percentage"].to_f
    end
  end

  json.total do
    json.vote_count total[:vote_count]
    json.voter_count total[:voter_count]
    json.percentage total[:percentage]
  end
end
