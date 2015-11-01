class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Voter.new # guest user (not logged in)
    set_role(user)
  end

  def admin(user)
    can :manage, :all
  end

  def voter(user)
    if signin_active? || voting_active?
      can :access, :elections
    end

    if signin_active?
      can :access, :sessions
    end

    if voting_active?
      can :access, :votes
    end
  end

  def signin_active?
    Vaalit::Config::SIGNIN_STARTS_AT <= Time.now &&
      Time.now <= Vaalit::Config::SIGNIN_ENDS_AT
  end

  def voting_active?
    Time.now < Vaalit::Config::SIGNIN_ENDS_AT + Vaalit::Config::VOTING_GRACE_PERIOD_MINUTES
  end

  private

  def set_role(user)
    case user.class.to_s
    when "Voter"
      send :voter, user
    when "AdminUser"
      send :admin, user
    else
      raise "Unknown user class: #{user.class.to_s}"
    end
  end
end