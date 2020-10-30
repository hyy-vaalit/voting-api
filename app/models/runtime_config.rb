# Dynamic configuration which changes during the runtime.
# For static configuration, see `config/initializers/000_config.rb`
class RuntimeConfig
  # User can sign in to vote.
  def self.vote_signin_active?
    now = Time.now

    voting_day?(now) && voting_time?(now)
  end

  # User can submit a vote.
  #
  # Allow a grace period to submit votes.
  # Only for users who have signed in before the sign in ended.
  def self.voting_active?
    now = Time.now

    elections_active?(now) && voting_time_with_grace_period?(now)
  end

  # Elections have started when vote sign in has been active at least once.
  def self.elections_started?
    Vaalit::Config::VOTE_SIGNIN_STARTS_AT <= Time.now
  end

  # Elections are ongoing.
  #
  # The first day of voting has started, but the last day of voting
  # has not ended yet (including the grace period)
  # and election has not terminated yet (when there are multiple voting periods).
  def self.elections_active?(now = Time.now)
    signin_has_started?(now) && now < election_terminates_at
  end

  def self.http_basic_auth?
    !Vaalit::Config::HTTP_BASIC_AUTH_USERNAME.nil?
  end

  private_class_method def self.signin_has_started?(now)
    Vaalit::Config::VOTE_SIGNIN_STARTS_AT <= now
  end

  private_class_method def self.voting_day?(now)
    signin_has_started?(now) && now <= Vaalit::Config::VOTE_SIGNIN_ENDS_AT
  end

  private_class_method def self.voting_time?(now)
    Time.parse(Vaalit::Config::VOTE_SIGNIN_DAILY_OPENING_TIME) < now &&
      now <= Time.parse(Vaalit::Config::VOTE_SIGNIN_DAILY_CLOSING_TIME)
  end

  private_class_method def self.voting_time_with_grace_period?(now)
    Time.parse(Vaalit::Config::VOTE_SIGNIN_DAILY_OPENING_TIME) <= now &&
      now < Time.parse(Vaalit::Config::VOTE_SIGNIN_DAILY_CLOSING_TIME) + Vaalit::Config::VOTING_GRACE_PERIOD_MINUTES
  end

  private_class_method def self.election_terminates_at
    Vaalit::Config::ELECTION_TERMINATES_AT + Vaalit::Config::VOTING_GRACE_PERIOD_MINUTES
  end
end
