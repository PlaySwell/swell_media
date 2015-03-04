module SwellMedia
	class SessionsController < Devise::SessionsController

		layout 'sessions'

		def create
			self.resource = warden.authenticate!( auth_options )

			sign_in( resource_name, resource )

			record_user_event( 'login', user: resource, guest_session: @guest_session, content: 'logged in.' ) 
			assign_anonymous_events( resource )

			sign_in_and_redirect( resource )
		end

		def new
			super
		end

	end
end