module SwellMedia

	class ApiAccessTokenController < ApplicationController

		protect_from_forgery :except => [:create, :info]

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

				# session.delete('devise.twitter_data')
				# session.delete('devise.facebook_data')
				session.delete('warden.user.User.key')

				render json: { status: :success, name: @guest_session.user.slug, full_name: @guest_session.user.full_name, email: @guest_session.user.email, token: @guest_session.access_token }

			elsif auth.present?

				#handle user save error
				render json: { status: :user_error, message: auth.user.errors.full_messages }


			end

		end

		def info

			auth = ApiAuthParser.parse( params )

			if auth.nil?

				#invalid auth
				render json: { status: :invalid_arguments, message: 'Invalid Arguments' }

			elsif auth.errors?

				#handle auth errors
				render json: { status: :authentication_error, message: auth.errors }

			else

				render json: { status: :success, registration: auth.registration?, name: auth.user.try(:slug), full_name: auth.user.try(:full_name), email: auth.user.try(:email) }

			end

		end

	end

end