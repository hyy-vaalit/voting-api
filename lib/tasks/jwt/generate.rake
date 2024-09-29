namespace :jwt do

  def generate(payload, secret, expiry_number)
    payload ||= { name: "i'm a service user" }
    expiry_number ||= "24"

    expiry_time = expiry_number.to_i.hours.from_now

    puts "Time.now: #{Time.now}"
    puts "Expiry: #{expiry_time} (expires in #{expires_in(expiry_time)} hours)"
    puts "Payload: #{payload}"

    token = JsonWebToken.encode payload, secret, expiry_time
    puts ""
    puts "HTTP Header:"
    puts "Authorization: Bearer #{token}"
    puts ""
    puts "Link to Rails server (rails s):"
    puts "#{Vaalit::Public::SITE_ADDRESS}/#/sign-in?token=#{token}"
    puts ""
    puts "Link to Frontend 'grunt serve' (port has been guessed):"
    puts "http://localhost:9000/#/sign-in?token=#{token}"
    puts ""
    puts "Hint: cmd-click in iTerm2 opens the link automatically in browser."
  end

  def expires_in(expiry)
    ((expiry - Time.now) / 1.hours).round
  end

  def verify(jwt, secret)
    decoded = JsonWebToken.decode jwt, secret
    if decoded.nil?
      puts "Token could not be decoded"
      return
    end

    payload = decoded.first
    expiry_time = Time.at(payload['exp']) if payload['exp'].present?

    puts "Full content:"
    puts decoded.to_s
    puts ""
    if expiry_time.present?
      puts "Expiry: #{expiry_time} (expires in #{expires_in(expiry_time)} hours)"
    else
      puts "Expiry: VALID FOREVER"
    end
    puts "Payload: #{payload}"
  end

  namespace :service_user do
    desc 'generate a JWT token for API access'
    task :generate, [:payload, :expiry_hours] => :environment do
      generate ENV['payload'],
               Vaalit::Config::JWT_SERVICE_USER_SECRET,
               ENV['expiry_hours']
    end

    desc 'verify a JWT token'
    task :verify, [:jwt] => :environment do
      verify ENV['jwt'], Vaalit::Config::JWT_SERVICE_USER_SECRET
    end
  end

  namespace :voter do
    desc 'generate a JWT token for Frontend access'
    task :generate, [:voter_id, :expiry_hours] => :environment do
      voter_id = ENV['voter_id'] || 1
      payload = { voter_id: voter_id.to_i }

      generate payload,
               Vaalit::Config::JWT_VOTER_SECRET,
               ENV['expiry_hours']
    end

    desc 'verify a JWT token'
    task :verify, [:jwt] => :environment do
      verify ENV.fetch('jwt'), Vaalit::Config::JWT_VOTER_SECRET
    end
  end
end
