require 'rails_helper'
require "cancan/matchers"

describe Vaalit::Elections do

  describe "authorization" do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    describe "voter" do
      let(:user) { FactoryBot.build(:voter) }

      context "when voting is ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(true)
        end

        it { should be_able_to(:access, :elections) }
        it { should be_able_to(:access, Election) }
        it { should be_able_to(:access, :votes) }
      end

      context "when voting is not ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(false)
          allow(RuntimeConfig).to receive(:vote_signin_active?).and_return(false)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end

      context "when signing in has ended but voting grace period is ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(true)
          allow(RuntimeConfig).to receive(:vote_signin_active?).and_return(false)
        end

        it { should be_able_to(:access, :elections) }
        it { should be_able_to(:access, Election) }
        it { should be_able_to(:access, :votes) }
      end
    end

    describe "service user" do
      let(:user) { FactoryBot.build(:service_user) }

      context "when voting is ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(true)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end

      context "when voting is not ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(false)
          allow(RuntimeConfig).to receive(:vote_signin_active?).and_return(false)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end

      context "when signing in has ended but voting grace period is ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(true)
          allow(RuntimeConfig).to receive(:vote_signin_active?).and_return(false)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end
    end

    describe "guest" do
      let(:user) { FactoryBot.build(:guest_user) }

      context "when voting is ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(true)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end

      context "when voting is not ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(false)
          allow(RuntimeConfig).to receive(:vote_signin_active?).and_return(false)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end

      context "when signing in has ended but voting grace period is ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(true)
          allow(RuntimeConfig).to receive(:vote_signin_active?).and_return(false)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end
    end

    describe "nil user" do
      let(:user) { nil }

      context "when voting is ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(true)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end

      context "when voting is not ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(false)
          allow(RuntimeConfig).to receive(:vote_signin_active?).and_return(false)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end

      context "when signing in has ended but voting grace period is ongoing" do
        before do
          allow(RuntimeConfig).to receive(:voting_active?).and_return(true)
          allow(RuntimeConfig).to receive(:vote_signin_active?).and_return(false)
        end

        it { should_not be_able_to(:access, :elections) }
        it { should_not be_able_to(:access, Election) }
        it { should_not be_able_to(:access, :votes) }
      end
    end
  end
end
