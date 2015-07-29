module SwellMedia

	class GoogleAnalyticsEventService

		USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"
		#"SwellMedia 1.0 Agent"

		def self.log( user_event, args = {} )
			puts "GoogleAnalyticsEventService.log" if SwellMedia.google_analytics_debug


			params = {
					v: 1,
					tid: SwellMedia.google_analytics_code,
					cid: (args[:client_id] || SecureRandom.uuid),
					t: 'event',
					ec: args[:category] || ( user_event.parent_obj.nil? ? 'Site Event' : user_event.parent_obj.class.name ),
					ea: args[:action] || user_event.name,
					el: args[:label] || user_event.parent_obj.to_s,
					ev: args[:value] || user_event.value || 0
			}

			user_agent = args[:user_agent] || user_event.guest_session.try(:user_agent) || USER_AGENT

			begin

				tracker = Staccato.tracker(SwellMedia.google_analytics_code, params[:cid])

				tracker.event(category: params[:ec], action: params[:ea], label: params[:el], value: params[:ev])

				return true
			rescue  Exception => ex
				puts "Google Analytics: EXCEPTION, params: #{params}, user_agent: #{user_agent}" if SwellMedia.google_analytics_debug

				logger.error ex.message
				logger.error ex.backtrace.join("\n")

				NewRelic::Agent.notice_error(ex) if defined?( NewRelic )
				return false
			end

		end


	end

end