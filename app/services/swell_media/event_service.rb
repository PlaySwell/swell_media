
module SwellMedia

	class EventService

		def self.log( name, args={} )
			return false unless name.present?
			return false unless args[:guest_session].present?

			event = UserEvent.new( name: name.to_s, guest_session_id: args[:guest_session].id )

			event.user_id = args[:user].try( :id )

			parent_obj = args[:on] || args[:obj]

			event.src = args[:guest_session].src
			event.ui_variant = args[:guest_session].ui_variant
			event.ui = args[:ui] if event.respond_to? ( :ui )

			event.session_cluster_created_at = Time.at( args.delete(:session_cluster_created_at) ) if args[:session_cluster_created_at].is_a? Integer
			event.session_cluster_created_at ||= args[:session_cluster_created_at]

			event.req_path = event.req_full_path = args[:req_path]
			event.req_path = event.req_full_path.split('?')[0] unless event.req_full_path.blank? || not( event.req_full_path.include?('?') ) #rescue true

			event.http_referrer = args[:guest_session].last_http_referrer

			event.category_id = parent_obj.try( :category_id )

			event.content = args[:content]

			rate = args[:rate] || 5.minutes

			event.publish_at = parent_obj.try( :publish_at ) || args[:publish_at] || Time.zone.now unless args[:unpublished]

			# setting owner_type so logging with nill owner doesn't populate owner_type with NilClass
			event.parent_obj_type = parent_obj.nil? ? nil : parent_obj.class.name
			event.parent_obj_id = parent_obj.try( :id )

			dup_events = UserEvent.where( name: event.name, guest_session_id: event.guest_session_id ).within_last( rate )
			dup_events = dup_events.by_object( parent_obj ) if dup_events.present? && parent_obj.present?
			# DO NOT record if existing events within rate
			return false if dup_events.count > 0

			event.save

			count_cache_field = "cached_#{name}_count"

			if parent_obj.present? && parent_obj.respond_to?( count_cache_field )
				parent_obj.class.name.constantize.increment_counter( count_cache_field, parent_obj.id )
			end


			GoogleAnalyticsEventService.log( event, args[:ga] || {} ) unless SwellMedia.google_analytics_code.nil? || args[:opt_out_google_analytics]


			return event

		end

	end

end