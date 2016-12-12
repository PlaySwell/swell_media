module SwellMedia

	class UserEventStat < ActiveRecord::Base
		self.table_name = 'user_event_stats'

		def self.generate_series( args = {} )
			unit = args[:by] || 'day'

			end_date = (args[:end_date] || Time.zone.now).to_date.end_of_day
			start_date = args[:start_date].to_date.beginning_of_day if args[:start_date]
			start_date ||= (end_date - (args[:length] || 30).try(unit)).to_date.beginning_of_day


			sql = self.where( starts_at: start_date..end_date ).group("date_trunc('#{unit}', user_event_stats.starts_at)").select("date_trunc('#{unit}', user_event_stats.starts_at) as date_unit, SUM( user_event_stats.event_count ) as count").to_sql

			query = <<-END
				SELECT
					date( date ),
					coalesce( count, 0 ) AS count
				FROM
					generate_series(
						'#{start_date}'::date,
						'#{end_date}'::date,
						'1 #{unit}') AS date
				LEFT OUTER JOIN
					(#{sql}) results
					ON (date = results.date_unit)
			END

			return self.connection.execute( query )
		end

		def self.find_or_create_and_increment_by_user_event( user_event )

			SwellMedia::UserEventStat.find_or_create_by( event_name: user_event.name, starts_at: user_event.created_at.beginning_of_day, ends_at: user_event.created_at.end_of_day ).increment!( :event_count )

		end

	end

end