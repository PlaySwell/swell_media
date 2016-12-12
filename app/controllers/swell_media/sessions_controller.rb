module SwellMedia
	class SessionsController < Devise::SessionsController

		layout 'sessions'

		def create
			self.resource = warden.authenticate( auth_options )

			if self.resource

				if sign_in( resource_name, resource )

					record_user_event( event: 'login', user: resource, content: 'logged in.' )
					assign_anonymous_events( resource )

					sign_in_and_redirect( resource )

				else

					set_flash 'login failed'

					redirect_to :back

				end

			else

				redirect_to self.try(:after_sign_in_failure_path) || '/login'

			end
		end

		def new
			super
		end

	end
end