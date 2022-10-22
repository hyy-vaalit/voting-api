class SessionLink
  include ExtendedPoroBehaviour

  attr_accessor :email,
                :voter

  before_validation :assign_voter
  validate :voter_exists?

  validates_presence_of :email

  def deliver
    return false unless valid?

    SessionLinkMailer.signup_link(voter.email, url).deliver_later
  end

  protected

  def voter_exists?
    if voter.blank?
      errors.add(:email, "Given email doesn't have any elections")
      errors.add(:email_error_key, ".not_eligible_in_any_election")
      return false
    end

    return true
  end

  def assign_voter
    self.voter = Voter.find_by_email(email)
  end

  private

  def jwt
    SessionToken
      .new(voter)
      .ephemeral_jwt(Vaalit::Config::EMAIL_LINK_JWT_EXPIRY_MINUTES)
  end

  def url
    "#{Vaalit::Public::SITE_ADDRESS}/#/sign-in?token=#{URI.encode_www_form_component(jwt)}"
  end
end
