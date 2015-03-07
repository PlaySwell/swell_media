module SwellMedia

	class UserEvent < ActiveRecord::Base
		self.table_name = 'user_events'

		enum status: { 'active' => 1, 'archive' => 2, 'trash' => 3 }
		enum availability: { 'anyone' => 1, 'logged_in_users' => 2, 'just_me' => 3 }

		belongs_to 		:user, class_name: SwellMedia.registered_user_class
		belongs_to 		:ref_user, class_name: 'User', foreign_key: :ref_user_id
		belongs_to		:rec_user, class_name: 'User', foreign_key: :rec_user_id
		belongs_to		:guest_session
		belongs_to		:parent_obj, polymorphic: true


		### Class Methods   	--------------------------------------

		def self.by_event( event )
			return scoped if event.nil?
			where( name: event.to_s )
		end

		def self.by_object( obj )
			return scoped if obj.nil?
			where( parent_obj_type: obj.class.name, parent_obj_id: obj.id )
		end

		def self.by_referring_user( user )
			return scoped if user.nil?
			where( ref_user_id: user.id )
		end

		def self.generate_daily_series( event='visit', start_date=1.month.ago, end_date=Time.zone.now )
			start_date = start_date.to_date.beginning_of_day
			end_date = end_date.to_date.end_of_day

			query = <<-END 
				SELECT
					date( date ),
					coalesce( count, 0 ) AS count
				FROM
					generate_series(
						'#{start_date}'::date,
						'#{end_date}'::date,
						'1 day') AS date
				LEFT OUTER JOIN
					(SELECT
						date_trunc('day', user_events.created_at) as day,
						count( user_events.id ) as count
						FROM user_events
						WHERE
							name = '#{event}'
							AND created_at >= '#{start_date}'
							AND created_at <= '#{end_date}'
						GROUP BY day) results
					ON (date = results.day) 
			END

			return self.connection.execute( query )
		end

		def self.dated_between( start_date=1.month.ago, end_date=1.month.from_now )
			start_date = start_date.beginning_of_day
			end_date = end_date.end_of_day

			where( "created_at between ? and ?", start_date, end_date )
		end

		def self.broadcast_events
			# these events are broadcast
			# where( name: [ 'visit', 'registration', 'add_video', 'complete', 'comment', 'upvote' ] )

			# verbose broadcasting.... TODO reset to above before launch
			where( "name is not null" )
		end

		def self.recent( num=10 )
			order( 'created_at desc' ).limit( num )
		end


		def self.user_stream( user, args={} )
			# todo: wire in args (time period, media only? broadcast only? )
			self.where( user_id: user.id )

			# todo or in joins on object subscriptions.....
			# where parent_obj in subscibed auctions, media
			# where user_id in subscribed users
			# where category_id in subscribed categories
		end


		def self.within_last( period=1.minute )
			period_ago = Time.zone.now - period
			where( "created_at >= ?", period_ago )
		end


		### Instance Methods  	--------------------------------------

		def user_display
			self.user || 'Guest'
		end

		def propogate_event

			if SwellMedia.google_analytics_code



			end

		end

	end
	
end