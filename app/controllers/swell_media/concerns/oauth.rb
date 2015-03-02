
require 'active_support/concern'

module SwellMedia
	module Concerns
		module Oauth
			extend ActiveSupport::Concern

			included do
				#scope :disabled, -> { where(disabled: true) }
			end

			protected
			def response_auth( response )

				credential = SwellMedia::OauthCredential.where( provider: response.provider, uid: response.uid ).first

				if current_user.nil? && credential.present?

					# login, with existing user's credential

					set_flash "#{credential.user} signed in"

					current_user.on_login

					credential.update( token: response.oauth_token )

					record_user_event( 'login', guest_session: @guest_ession, user: current_user, on: current_user, content: 'Login' )

					login_redirect( credential.user )

				elsif current_user.present? && credential.present?

					# login, new credential on existing user.

					credential = current_user.oauth_credentials.create!( response.credential_fields )

					set_flash "#{credential.provider} account added."

					login_redirect( current_user )

				else

					# new registration

					user = User.new_from_response( response )

					user.email = params[:email] if params[:email].present?

					if user.email.blank?

						@no_fb_closer = true
						@user = user

						render 'swell_media/oauth/create', layout: 'swell_media/registration'

					elsif user.save

						@new_registration = user
						registration_success user

						set_flash "Registration successful"

						record_user_event( 'registration', guest_session: @guest_ession, user: user, on: user, content: 'Registration successful' )
						record_user_event( 'login', guest_session: @guest_ession, user: user, on: user, content: 'Login' )

						user.on_registration

						login_redirect user

					else

						set_flash 'Something went wrong', :error, user

						begin
							logger.error user.errors.full_messages
							#NewRelic::Agent.notice_error(StandardError.new("OauthController#facebook (new user) Something went wrong - #{user.errors.full_messages.to_json} - #{user.as_json}"))
							session[:omniauth] = request.env["omniauth.auth"].except('extra')
						rescue => e
							logger.error e.message
							logger.error e.backtrace.join("\n")
						end

						redirect_to '/'
					end
				end

			end

			def registration_success( user )

			end


			def login_redirect( user )

				redirect_to after_sign_in_path_for( user )

			end



		end
	end
end