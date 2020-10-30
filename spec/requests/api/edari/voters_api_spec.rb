require 'rails_helper'
require "cancan/matchers"

describe Vaalit::Voters::VotersApi do

  describe "authorization" do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    context "when current user is a voter" do
      let(:user) { FactoryBot.build(:voter) }

      it { should_not be_able_to(:access, :voters) }
    end

    context "when current user is a guest" do
      let(:user) { FactoryBot.build(:guest_user) }

      it { should_not be_able_to(:access, :voters) }
    end

    context "when current user is nil" do
      let(:user) { nil }

      it { should_not be_able_to(:access, :voters) }
    end

    context "when current user is a service user" do
      let(:user) { FactoryBot.build(:service_user) }

      before do
        allow(RuntimeConfig).to receive(:elections_started?).and_return true
        allow(RuntimeConfig).to receive(:elections_active?).and_return true
      end

      it { should be_able_to(:access, :voters) }
    end
  end

  describe "creating a new voter" do
    before do
      allow_any_instance_of(Vaalit::JwtHelpers)
        .to receive(:current_service_user) { ServiceUser.new }
      allow(RuntimeConfig).to receive(:elections_started?).and_return(true)
      allow(RuntimeConfig).to receive(:elections_active?).and_return(true)

      @election = FactoryBot.create :election, :edari_election
      @faculty = FactoryBot.create :faculty
      @department = FactoryBot.create :department
      @voter_data = {
        "name": "Etu Suku",
        "email": "etu.suku@example.com",
        "faculty_code": @faculty.code,
        "department_code": @department.code,
        "ssn": "123456-1234",
        "phone": "040-1234 555",
        "student_number": "1234567"
      }
      @headers = { "ACCEPT": "application/json" }
    end

    context "when voter does not exist yet" do
      it 'creates a new voter' do
        expect(Voter.count).to eq 0

        post "/api/elections/#{@election.id}/voters",
             params: { voter: @voter_data },
             headers: @headers

        expect(response).to be_successful
        expect(json["name"]).to eq "Etu Suku"
        expect(json["email"]).to eq "etu.suku@example.com"
        expect(Voter.count).to eq 1

        persisted_voter = Voter.first
        expect(persisted_voter.name).to eq @voter_data[:name]
        expect(persisted_voter.email).to eq @voter_data[:email]
        expect(persisted_voter.ssn).to eq @voter_data[:ssn]
        expect(persisted_voter.phone).to eq @voter_data[:phone]
        expect(persisted_voter.student_number).to eq @voter_data[:student_number]
        expect(persisted_voter.faculty_id).to eq @faculty.id
        expect(persisted_voter.department_id).to eq @department.id
      end

      it 'creates a voting right' do
        expect(VotingRight.count).to eq 0
        expect(Voter.count).to eq 0

        post "/api/elections/#{@election.id}/voters",
             params: { voter: @voter_data },
             headers: @headers

        expect(VotingRight.count).to eq 1
        voting_right = VotingRight.first
        voter = Voter.first

        expect(voting_right.voter).to eq voter
      end
    end
  end
end
