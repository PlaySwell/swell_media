module SwellMedia

	class GoogleAnalyticsEventService

		USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"
		#"SwellMedia 1.0 Agent"

		def self.log( user_event, args = {} )

			params = {
					v: 1,
					tid: SwellMedia.google_analytics_code,
					cid: (args[:client_id] || '555'),
					t: 'event',
					ec: args[:category] || ( user_event.parent_obj.nil? ? 'Site Event' : user_event.parent_obj.class.name ),
					ea: args[:action] || user_event.name,
					el: args[:label] || user_event.parent_obj.to_s,
					ev: args[:value] || user_event.value || 0
			}

			begin
				response = RestClient.post(
						'http://www.google-analytics.com/collect',
						params,
						timeout: 4,
						open_timeout: 4,
						user_agent: args[:user_agent] || user_event.guest_session.try(:user_agent) || USER_AGENT )

				puts "Google Analytics: response.code => #{response.code}"

				return response.code == 200
			rescue  RestClient::Exception => rex
				logger.error rex.message
				logger.error rex.backtrace.join("\n")
				return false
			end

		end


	end

end