require './lib/support/imported_csv_coalition'

namespace :db do
  namespace :seed do
    namespace :edari do
      desc 'seed coalitions from stdin in csv format'
      task :coalitions => :environment do
        ActiveRecord::Base.transaction do
          begin
            if Coalition.count != 0
              raise "Expected Coalition table to be empty (has #{Coalition.count} coalitions)."
            end

            separator = ","
            encoding = "UTF-8"
            count = 0

            puts ""
            puts "==================== COALITIONS ======================="
            puts "Paste Coalitions in CSV format, finally press ^D"
            puts ""
            puts "Retrieve the CSV using the link in the frontpage:"
            puts "https://ehdokastiedot.hyy.fi/manage/electoral_coalitions.csv"
            puts ""
            puts "Expected format is (without header):"
            puts "name,numbering_order,short_name,alliance_count"
            puts ""

            lines = $stdin.readlines

            lines.each do |csv_row|
              count = count + 1

              CSV.parse(csv_row, col_sep: separator, encoding: encoding) do |csv_coalition|
                Support::ImportedCsvCoalition.create_from! csv_coalition, election_id: Election.first.id
              end
            end

            puts "Imported #{count} coalitions from STDIN."
            puts "Database has now #{Coalition.count} coalitions."
          end
        end
      end
    end
  end
end
