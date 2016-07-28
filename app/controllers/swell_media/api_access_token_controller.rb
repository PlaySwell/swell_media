module SwellMedia

	class ApiAccessTokenController < ApplicationController

		protect_from_forgery :except => [:create]

		def create

			auth = ApiAuthParser.parse( params )

			if auth.nil?

				#invalid auth
				render json: { status: :invalid_arguments, message: 'Invalid Arguments' }

			elsif auth.errors?

				#handle auth errors
				render json: { status: :authentication_error, message: auth.errors }

			elsif auth.user.save

				if auth.registration?

					record_user_event( event: 'registration', user: auth.user, obj: auth.user, content: "registered via #{auth.provider}." )

				else

					record_user_event( event: 'login', user: auth.user, content: 'logged in.' )

				end

				sign_in( 'User', auth.user )

				@guest_session.user = auth.user
				@guest_session.access_token = SecureRandom.uuid
				@guest_session.device_id = params[:device_id]
				@guest_session.save

				render json: { status: :success, access_token: @guest_session.access_token }

			elsif auth.present?

				#handle user save error
				render json: { status: :user_error, message: auth.user.errors.full_messages }


			end

		end

		def show

			session = GuestSession.find_by( access_token: params[:id], device_id: params[:api_access_device_id] )

			render json: { access_token: session.access_token, user_id: session.user_id }

		end

	end

end