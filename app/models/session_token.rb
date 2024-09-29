# A JWT Session Token provides access to the API.
#
# This class provides two kinds of tokens:
# 1) Long-lived Session JWT
# 2) Ephemeral Sign In JWT
#
# User first provides the API with short-lived Sign In token which is then
# exchanged for a long-lived Session Token.
#
# JWT Session Token is submitted by the user-agent in each authorized request.
class SessionToken

  # User who is signed in.
  attr_reader :user

  # Params:
  # voter => an instance of `Voter` who is to be signed in
  def initialize(voter)
    @user = User.new voter
  end

  def valid?
    validate
  end

  # Long-lived JWT used for API access.
  def jwt
    payload = {
      voter_id: @user.voter.id,
      email: @user.voter.email
    }

    JsonWebToken.encode payload,
                        Vaalit::Config::JWT_VOTER_SECRET,
                        Vaalit::Config::VOTER_SESSION_JWT_EXPIRY_MINUTES.from_now
  end

  # Short-lived JWT which is used in the sign in and exchanged for a session jwt.
  def ephemeral_jwt(lifetime = Vaalit::Config::SIGN_IN_JWT_EXPIRY_SECONDS)
    payload = { voter_id: @user.voter.id }
    expiry = lifetime.from_now

    JsonWebToken.encode payload,
                        Vaalit::Config::JWT_VOTER_SECRET,
                        expiry
  end

  # List of elections displayed in frontpage.
  def elections
    @user.voter.elections
  end

  # Voter's own info.
  def voter
    @user.voter
  end

  protected
  begin

    def validate
      not user.blank?
    end

  end

end
