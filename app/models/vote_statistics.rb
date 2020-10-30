require 'json'

# Print json in console with:
#   puts JSON.pretty_generate(VoteStatistics.by_faculty)
class VoteStatistics
  def self.by_hour_as_json
    stats = []
    total = {}

    by_hour.each do |data|
      row = {}

      key = "#{data.year.to_i}-#{data.month.to_i}-#{data.day.to_i} #{data.hour.to_i}:59"
      row[key] = data.vote_count.to_i

      stats << row
    end

    total[:vote_count] = ImmutableVote.count
    total[:percentage] = (100.0 * ImmutableVote.count / Voter.count).round(2)
    total[:voter_count] = Voter.count

    view_context.render(
      template: "vote_statistics/votes_by_hour.json.jbuilder",
      locals: { stats: stats, total: total }
    )
  end

  def self.by_faculty_as_json
    stats = by_faculty.map(&:as_json)

    total = {
      vote_count: ImmutableVote.count,
      voter_count: Voter.count,
      percentage: (100.0 * ImmutableVote.count / Voter.count).round(2)
    }

    view_context.render(
      template: "vote_statistics/votes_by_faculty.json.jbuilder",
      locals: {
        stats: stats,
        total: total
      }
    )
  end

  # All votes of every election grouped by hour.
  # ActiveRecord stores `datetime` attributes in the database without timezone,
  # although it stores all the values as UTC.
  # => created_at   | timestamp without time zone
  # As a workaround, the timezone is first cast as UTC and then to localtime.
  # Otherwise the hour is wrong by the amount of offset (+0200 or +0300).
  def self.by_hour
    ImmutableVote
      .select("
        date_part('hour', created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Helsinki') AS hour,
        date_part('day', created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Helsinki') AS day,
        date_part('month', created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Helsinki') AS month,
        date_part('year', created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Helsinki') AS year,
        COUNT(*) as vote_count
      ").group(
        "hour, day, month, year"
      ).order(
        "year, month, day, hour ASC"
      )
  end

  # All votes grouped by Faculty
  def self.by_faculty
    Faculty.find_by_sql <<-EOSQL.squish
      WITH voters_by_faculty as (
       SELECT
          faculties.id AS faculty_id,
          count(*) as voter_count
        FROM voters
        INNER JOIN faculties ON faculties.id = voters.faculty_id
        GROUP BY 1
      ), voted_by_faculty as (
         SELECT
            faculties.id AS faculty_id,
            count(*) as vote_count
          FROM voters
          INNER JOIN faculties ON faculties.id = voters.faculty_id
          INNER JOIN voting_rights
            ON voting_rights.voter_id = voters.id
            AND voting_rights.used = true

          GROUP BY 1
      )
      SELECT
        faculties.id,
        faculties.name,
        voter_count,
        COALESCE(vote_count, 0) AS vote_count,
        round(100.0 * COALESCE(vote_count, 0) / voter_count, 2) AS percentage
      FROM
        faculties
      LEFT OUTER JOIN
        voters_by_faculty ON voters_by_faculty.faculty_id = faculties.id
      LEFT OUTER JOIN
        voted_by_faculty ON voted_by_faculty.faculty_id = faculties.id
      ORDER BY percentage DESC;
    EOSQL
  end

  private_class_method def self.view_context
    ActionView::Base.new(ActionController::Base.view_paths)
  end
end
