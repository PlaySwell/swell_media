
module SwellMedia

	class GuestSession < ActiveRecord::Base
		self.table_name = 'guest_sessions'

		enum device_format: { 'desktop' => 0, 'tablet' => 1, 'phone' => 2, 'app' => 3 }

		before_save 	:parse_agent

		belongs_to	:user, class_name: SwellMedia.registered_user_class
		
		has_many 	:user_events

		def self.create_from_request( request, args={} )
			# todo -- more
			session = self.new( user: args[:user],
								ip: request.ip, 
								user_agent: request.user_agent, 
								original_http_referrer: request.referrer,
								last_http_referrer: request.referrer,
								language: request.env['HTTP_ACCEPT_LANGUAGE'], 
								params: {}, properties: {} )
			
			if args[:params].present?
				session.traffic_source = args[:params][:utm_source]
				session.traffic_campaign = args[:params][:utm_campaign]
				session.traffic_medium = args[:params][:utm_medium]
				session.ui_variant = args[:params][:var] || args[:params][:ui_variant]
				args[:params].each do |k, v|
					session.params[k] = v
				end
			end
			
			session.save
			
			return session
		end


		def to_s
			"#{self.id}:#{self.platform}_#{self.browser_name}#{self.browser_version}_#{self.language}"
		end


		private
			def parse_agent
				browser = Browser.new( ua: self.user_agent )
				self.browser_name = browser.name
				self.browser_version = browser.version
				self.platform = browser.platform
				self.device_format = 'tablet' if browser.tablet?
				self.device_format = 'phone' if browser.mobile?
				self.device_format = 'app' if (self.user_agent =~ /^com.shopswell.desktop/).present?
				self.human = not( browser.bot? )
			end

	end

end