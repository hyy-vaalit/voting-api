require './lib/support/imported_csv_immutable_vote'

namespace :db do
  namespace :seed do
    namespace :edari do
      namespace :demo do
        desc 'demo votes from 2009 elections (requires candidates)'
        task :votes => :environment do
          puts "Seeding votes ..."

          if ImmutableVote.count > 0
            raise "Did not expect any votes be present, has #{ImmutableVote.count} votes"
          end

          filename = "./lib/support/data/2009_votes.csv"
          separator = ","
          encoding = "UTF-8"
          count = 0

          CSV.foreach(filename,
                        col_sep: separator,
                        encoding: encoding,
                        headers: true) do |csv_vote|

            count = count + 1

            Support::ImportedCsvImmutableVote.create_from! csv_vote,
                                                  created_at: rand(5 * 24 * 60).minutes.ago,
                                                  election_id: Election.first.id
          end

          puts "Imported votes for #{count} candidates"
          puts "END: Database has now #{ImmutableVote.count} votes."
        end
      end
    end
  end
end
