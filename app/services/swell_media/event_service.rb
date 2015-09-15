
module SwellMedia

	class EventService

		def self.log( args={} )

			return false unless args[:event].present?

			if args[:guest_session].present?
				args[:guest_session_attributes] = args[:guest_session].attributes
			elsif !args[:guest_session_attributes].present?
				return false
			end

			args[:update_caches] = true if args[:update_caches].nil?

			event = UserEvent.new( name: args[:event].to_s, guest_session_id: args[:guest_session_attributes][:id] )

			event.user_id = args[:user].try( :id )

			parent_obj = args[:on] || args[:parent_obj]

			activity_obj = args[:obj] || args[:activity_obj]

			event.parent_controller = args[:parent_controller]
			event.parent_action = args[:parent_action]

			event.traffic_source = args[:guest_session_attributes][:traffic_source]
			event.traffic_campaign = args[:guest_session_attributes][:traffic_campaign]
			event.traffic_medium = args[:guest_session_attributes][:traffic_medium]

			event.traffic_src_user = args[:guest_session_attributes][:traffic_src_user]
			event.content_src_user = args[:guest_session_attributes][:content_src_user]

			event.ui_variant = args[:params][:ui_variant] || args[:guest_session_attributes][:ui_variant]
			event.ui = args[:params][:ui]

			event.session_cluster_created_at = Time.at( args.delete(:session_cluster_created_at) ) if args[:session_cluster_created_at].is_a? Integer
			event.session_cluster_created_at ||= args[:session_cluster_created_at]

			event.req_path = event.req_full_path = args[:req_path]
			event.req_path = event.req_full_path.split('?')[0] unless event.req_full_path.blank? || not( event.req_full_path.include?('?') ) #rescue true

			event.http_referrer = args[:guest_session_attributes][:last_http_referrer]

			event.category_id = parent_obj.try( :category_id )

			event.content = args[:content]

			event.detail_data = args[:detail_data]

			rate = args[:rate] || UserEvent.rates[ event.name.to_sym ] || UserEvent.rates[ :default ]

			event.publish_at = parent_obj.try( :publish_at ) || args[:publish_at] || Time.zone.now unless args[:unpublished]

			# setting owner_type so logging with nill owner doesn't populate owner_type with NilClass
			event.parent_obj_type = parent_obj.nil? ? nil : parent_obj.class.name
			event.parent_obj_id = parent_obj.try( :id )
			event.activity_obj_type = activity_obj.nil? ? nil : activity_obj.class.name
			event.activity_obj_id = activity_obj.try( :id )

			dup_events = UserEvent.where( name: event.name, guest_session_id: event.guest_session_id ).within_last( rate ).order( created_at: :asc )

			if event.activity_obj_id.present?
				dup_events = dup_events.where( activity_obj_id: activity_obj.id, parent_obj_id: activity_obj.class.name )
			elsif event.parent_obj_id.present?
				dup_events = dup_events.by_object( parent_obj )
			elsif event.name == 'page_view'
				dup_events = dup_events.where( parent_controller: event.parent_controller, parent_action: event.parent_action )
			end

			# DO NOT record if existing events within rate
			if dup_events.count > 0
				if event.args[:params][:page].present?
					dup_events.last.update( value: event.args[:params][:page], value_type: 'page_num' )
				end
				return false
			else
				event.save
				count_cache_field = "cached_#{name}_count"

				if parent_obj.present? && parent_obj.respond_to?( count_cache_field ) && args[:update_caches]
					if event.parent_action == 'create'
						parent_obj.class.name.constantize.increment_counter( count_cache_field, parent_obj.id )
					elsif event.parent_action == 'destroy'
						parent_obj.class.name.constantize.decrement_counter( count_cache_field, parent_obj.id )
					end
				end

				GoogleAnalyticsEventService.log( event, { client_id: args[:ga_client_id] } ) unless !SwellMedia.google_analytics_event_logging || args[:opt_out_google_analytics]

				return event
			end

		end

	end

end