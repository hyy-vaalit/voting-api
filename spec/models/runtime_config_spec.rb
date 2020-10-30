require 'rails_helper'

RSpec.describe RuntimeConfig, type: :model do

  before do
    Timecop.freeze "2015-11-02 09:00:00 +0200"
    stub_const("Vaalit::Config::VOTE_SIGNIN_STARTS_AT", 3.days.ago)
    stub_const("Vaalit::Config::VOTE_SIGNIN_ENDS_AT", 1.day.from_now)
    stub_const("Vaalit::Config::ELECTION_TERMINATES_AT", 1.week.from_now)
    stub_const("Vaalit::Config::VOTING_GRACE_PERIOD_MINUTES", 5.minutes)
    stub_const("Vaalit::Config::VOTE_SIGNIN_DAILY_OPENING_TIME", "9:00")
    stub_const("Vaalit::Config::VOTE_SIGNIN_DAILY_CLOSING_TIME", "18:00")
  end

  after do
    hide_const("Vaalit::Config::VOTE_SIGNIN_STARTS_AT")
    hide_const("Vaalit::Config::VOTE_SIGNIN_ENDS_AT")
    hide_const("Vaalit::Config::ELECTION_TERMINATES_AT")
    hide_const("Vaalit::Config::VOTING_GRACE_PERIOD_MINUTES")
    hide_const("Vaalit::Config::VOTE_SIGNIN_DAILY_OPENING_TIME")
    hide_const("Vaalit::Config::VOTE_SIGNIN_DAILY_CLOSING_TIME")
    Timecop.return
  end

  context "voting has not started yet" do
    before do
      stub_const("Vaalit::Config::VOTE_SIGNIN_STARTS_AT", 1.hour.from_now)
      stub_const("Vaalit::Config::VOTE_SIGNIN_ENDS_AT", 2.hours.from_now)
    end

    it "vote signin is not active" do
      expect(RuntimeConfig.vote_signin_active?).to be false
    end

    it "voting is not active" do
      expect(RuntimeConfig.voting_active?).to be false
    end

    it "elections are not active" do
      expect(RuntimeConfig.elections_active?).to be false
    end

    it "elections have not started" do
      expect(RuntimeConfig.elections_started?).to be false
    end
  end

  context "voting started yesterday but it's not yet daily opening time" do
    before do
      stub_const("Vaalit::Config::VOTE_SIGNIN_STARTS_AT", 1.day.ago)
      stub_const("Vaalit::Config::VOTE_SIGNIN_ENDS_AT", 1.day.from_now)
      stub_const("Vaalit::Config::VOTE_SIGNIN_DAILY_OPENING_TIME",
                 5.minutes.from_now.localtime.strftime('%H:%M'))
      stub_const("Vaalit::Config::VOTE_SIGNIN_DAILY_CLOSING_TIME",
                 1.hour.from_now.localtime.strftime('%H:%M'))
    end

    it "vote signin is not active" do
      expect(RuntimeConfig.vote_signin_active?).to be false
    end

    it "voting is not active" do
      expect(RuntimeConfig.voting_active?).to be false
    end

    it "elections are active" do
      expect(RuntimeConfig.elections_active?).to be true
    end

    it "elections have started" do
      expect(RuntimeConfig.elections_started?).to be true
    end
  end

  context "voting day is over but continues the next day" do
    before do
      stub_const("Vaalit::Config::VOTE_SIGNIN_STARTS_AT", 3.days.ago)
      stub_const("Vaalit::Config::VOTE_SIGNIN_ENDS_AT", 1.day.from_now)
      stub_const("Vaalit::Config::VOTING_GRACE_PERIOD_MINUTES", 5.minutes)
    end

    context "grace period is active" do
      before do
        # Use Timecop gem if test starts to fail for running too long.
        stub_const("Vaalit::Config::VOTE_SIGNIN_DAILY_CLOSING_TIME",
                   Time.now.localtime.strftime('%H:%M'))
      end

      it "vote signin is not active" do
        expect(RuntimeConfig.vote_signin_active?).to be false
      end

      it "voting is active" do
        expect(RuntimeConfig.voting_active?).to be true
      end

      it "elections are active" do
        expect(RuntimeConfig.elections_active?).to be true
      end

      it "elections have started" do
        expect(RuntimeConfig.elections_started?).to be true
      end
    end

    context "grace period is over" do
      before do
        stub_const("Vaalit::Config::VOTE_SIGNIN_DAILY_CLOSING_TIME",
                   301.seconds.ago.localtime.strftime('%H:%M'))
      end

      it "vote signin is not active" do
        expect(RuntimeConfig.vote_signin_active?).to be false
      end

      it "voting is not active" do
        expect(RuntimeConfig.voting_active?).to be false
      end

      it "elections are active" do
        expect(RuntimeConfig.elections_active?).to be true
      end

      it "elections have started" do
        expect(RuntimeConfig.elections_started?).to be true
      end
    end

  end

  context "first period of voting has ended" do
    before do
      stub_const("Vaalit::Config::VOTE_SIGNIN_STARTS_AT", 3.days.ago)
      stub_const("Vaalit::Config::VOTING_GRACE_PERIOD_MINUTES", 5.minutes)
    end

    context "grace period is active" do
      before do
        stub_const("Vaalit::Config::VOTE_SIGNIN_ENDS_AT", 299.seconds.ago)
        stub_const("Vaalit::Config::ELECTION_TERMINATES_AT", 1.week.from_now)
      end

      it "vote signin is not active" do
        expect(RuntimeConfig.vote_signin_active?).to be false
      end

      it "voting is active" do
        expect(RuntimeConfig.voting_active?).to be true
      end

      it "elections are active" do
        expect(RuntimeConfig.elections_active?).to be true
      end

      it "elections have started" do
        expect(RuntimeConfig.elections_started?).to be true
      end
    end

    context "grace period is over" do
      before do
        stub_const("Vaalit::Config::VOTE_SIGNIN_ENDS_AT", 300.seconds.ago)
        stub_const("Vaalit::Config::ELECTION_TERMINATES_AT", 300.seconds.ago)
      end

      it "vote signin is not active" do
        expect(RuntimeConfig.vote_signin_active?).to be false
      end

      it "voting is not active" do
        expect(RuntimeConfig.voting_active?).to be false
      end

      it "elections are not active" do
        expect(RuntimeConfig.elections_active?).to be false
      end

      it "elections have started" do
        expect(RuntimeConfig.elections_started?).to be true
      end
    end
  end

  context "second period of voting has ended" do
    before do
      stub_const("Vaalit::Config::VOTE_SIGNIN_STARTS_AT", 3.days.ago)
      stub_const("Vaalit::Config::VOTING_GRACE_PERIOD_MINUTES", 5.minutes)
    end

    context "grace period is active" do
      before do
        stub_const("Vaalit::Config::VOTE_SIGNIN_ENDS_AT", 299.seconds.ago)
        stub_const("Vaalit::Config::ELECTION_TERMINATES_AT", 299.second.ago)
      end

      it "vote signin is not active" do
        expect(RuntimeConfig.vote_signin_active?).to be false
      end

      it "voting is active" do
        expect(RuntimeConfig.voting_active?).to be true
      end

      it "elections are active" do
        expect(RuntimeConfig.elections_active?).to be true
      end

      it "elections have started" do
        expect(RuntimeConfig.elections_started?).to be true
      end
    end

    context "grace period is over" do
      before do
        stub_const("Vaalit::Config::VOTE_SIGNIN_ENDS_AT", 301.seconds.ago)
        stub_const("Vaalit::Config::ELECTION_TERMINATES_AT", 301.second.ago)
      end

      it "vote signin is not active" do
        expect(RuntimeConfig.vote_signin_active?).to be false
      end

      it "voting is not active" do
        expect(RuntimeConfig.voting_active?).to be false
      end

      it "elections are not active" do
        expect(RuntimeConfig.elections_active?).to be false
      end

      it "elections have started" do
        expect(RuntimeConfig.elections_started?).to be true
      end
    end
  end

  describe "http basic auth" do
    after do
      hide_const 'HTTP_BASIC_AUTH_USERNAME'
      hide_const 'HTTP_BASIC_AUTH_PASSWORD'
    end

    context "when username is set" do
      before do
        stub_const("Vaalit::Config::HTTP_BASIC_AUTH_USERNAME", 'user')
      end

      it 'is enabled' do
        expect(RuntimeConfig.http_basic_auth?).to be true
      end
    end

    context "when username is blank" do
      before do
        stub_const("Vaalit::Config::HTTP_BASIC_AUTH_USERNAME", '')
      end

      it 'is enabled' do
        expect(RuntimeConfig.http_basic_auth?).to be true
      end
    end

    context "when username is set but password is not set" do
      before do
        stub_const("Vaalit::Config::HTTP_BASIC_AUTH_USERNAME", '')
      end

      it 'is enabled' do
        expect(RuntimeConfig.http_basic_auth?).to be true
      end
    end

    context "when username is not set" do
      before do
        stub_const("Vaalit::Config::HTTP_BASIC_AUTH_USERNAME", nil)
      end

      it 'is disabled' do
        expect(RuntimeConfig.http_basic_auth?).to be false
      end
    end

    context "when username is not set but password is set" do
      before do
        stub_const("Vaalit::Config::HTTP_BASIC_AUTH_USERNAME", nil)
        stub_const("Vaalit::Config::HTTP_BASIC_AUTH_PASSWORD", 'sekrit')
      end

      it 'is disabled' do
        expect(RuntimeConfig.http_basic_auth?).to be false
      end
    end
  end
end
