module SwellMedia

	class GoogleAnalyticsEventService

		USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"
		#"SwellMedia 1.0 Agent"

		def self.log( user_event, args = {} )
			puts "GoogleAnalyticsEventService.log" if SwellMedia.google_analytics_debug

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

			user_agent = args[:user_agent] || user_event.guest_session.try(:user_agent) || USER_AGENT

			begin
				endpoint = 'https://www.google-analytics.com/collect'
				endpoint = 'https://www.google-analytics.com/debug/collect' if SwellMedia.google_analytics_debug

				response = RestClient.post(
						endpoint,
						params,
						timeout: 4,
						open_timeout: 4,
						user_agent: user_agent )

				if SwellMedia.google_analytics_debug
					puts "Google Analytics: response.code => #{response.code}, params: #{params}, user_agent: #{user_agent}\n#{response.body }"

					response_data = JSON.parse response.body

					if not( response_data['hitParsingResult'].is_a?( Array ) ) || response_data['hitParsingResult'].count == 0 || !response_data['hitParsingResult'].first['valid']
						logger.error "Google Analytics INVALID #{response_data['hitParsingResult'].first}"

						NewRelic::Agent.notice_error( Exception.new( "Google Analytics INVALID #{response_data['hitParsingResult'].first}" ) ) if defined?( NewRelic )
					end


				end

				return response.code == 200
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