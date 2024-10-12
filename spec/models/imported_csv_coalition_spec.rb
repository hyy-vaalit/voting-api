require 'rails_helper'
require './lib/support/imported_csv_coalition'

RSpec.describe Support::ImportedCsvCoalition, type: :model do
  describe "Creation" do

    before(:all) do
      sep = ","
      data  = 'Iso Vaalirengas,1,isohko,16'
      @rows = []

      CSV.parse(data, col_sep: sep) do |row|
        @rows << row
      end

    end

    it "builds from csv" do
      imported_coalition = Support::ImportedCsvCoalition.build_from(@rows.first)

      expect(imported_coalition.name).to eq("Iso Vaalirengas")
      expect(imported_coalition.numbering_order).to eq("1")
      expect(imported_coalition.short_name).to eq("isohko")
      expect(imported_coalition.alliance_count).to eq("16")
    end

    it "creates from csv" do
      election = FactoryBot.create :election

      coalition = Support::ImportedCsvCoalition.create_from!(@rows.first, election_id: election.id)

      expect(coalition.class).to eq Coalition
      expect(coalition.name).to eq("Iso Vaalirengas")
      expect(coalition.numbering_order).to eq(1)
      expect(coalition.short_name).to eq("isohko")
      #TODO: expect(coalition.expected_alliance_count).to eq(16)
    end
  end
end
