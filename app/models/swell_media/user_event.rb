module SwellMedia

	class UserEvent < ActiveRecord::Base
		self.table_name = 'user_events'

		enum status: { 'active' => 1, 'archive' => 2, 'trash' => 3 }
		enum availability: { 'anyone' => 1, 'logged_in_users' => 2, 'just_me' => 3 }

		belongs_to 		:user
		belongs_to 		:ref_user, class_name: 'User', foreign_key: :ref_user_id
		belongs_to		:rec_user, class_name: 'User', foreign_key: :rec_user_id
		belongs_to		:guest_session
		belongs_to		:parent_obj, polymorphic: true


		### Class Methods   	--------------------------------------

		def self.by_object( obj )
			return scoped if obj.nil?
			where( parent_obj_type: obj.class.name, parent_obj_id: obj.id )
		end

		def self.by_referring_user( user )
			return scoped if user.nil?
			where( ref_user_id: user.id )
		end

		def self.dated_between( start_date=1.month.ago, end_date=1.month.from_now )
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

		def self.recommendations
			where( "ref_user_id is not null" ).where( name: 'impression' )
		end

		
		def self.record( name, args={} )
			return false unless name.present?
			return false unless args[:guest_session].present?
			
			event = self.new( name: name.to_s, guest_session_id: args[:guest_session].id )
			
			event.user_id = args[:user].try( :id )
			event.ref_user_id = args[:ref_user].try( :id )

			parent_obj = args[:on] || args[:obj]

			event.http_referrer = args[:guest_session].last_http_referrer

			event.category_id = parent_obj.try( :category_id )

			event.rec_user_id = args[:rec_user].try( :id )
			event.content = args[:content]

			rate = args[:rate] || 5.minutes

			event.publish_at = parent_obj.try( :publish_at ) || args[:publish_at] || Time.zone.now unless args[:unpublished]

			# setting owner_type so logging with nill owner doesn't populate owner_type with NilClass
			event.parent_obj_type = parent_obj.nil? ? nil : parent_obj.class.name
			event.parent_obj_id = parent_obj.try( :id )

			dup_events = self.where( name: event.name, guest_session_id: event.guest_session_id ).within_last( rate )
			dup_events = dup_events.by_object( parent_obj ) if dup_events.present? && parent_obj.present?
			# DO NOT record if existing events within rate
			return false if dup_events.count > 0
			
			event.save
			
			count_cache_field = "cached_#{name}_count"

			if parent_obj.present? && parent_obj.respond_to?( count_cache_field )
				parent_obj.class.name.constantize.increment_counter( count_cache_field, parent_obj.id )
			end

			return event

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
	end
	
end