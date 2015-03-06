
require 'active_support/concern'

module SwellMedia
	module Concerns
		module Oauth
			extend ActiveSupport::Concern

			include Devise::Controllers::Helpers
			include Devise::Controllers::SignInOut

			included do
				#scope :disabled, -> { where(disabled: true) }
			end

			protected
			def response_auth( response )

				credential = SwellMedia::OauthCredential.where( provider: response.provider, uid: response.uid ).first

				if current_user.nil? && credential.present?

					# login, with existing user's credential

					set_flash "#{credential.user} signed in"

					credential.user.on_login

					credential.update( token: response.oauth_token )

					record_user_event( 'login', guest_session: @guest_ession, user: credential.user, on: credential.user, content: 'Login' )

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

						render 'swell_media/oauth/create', layout: 'sessions'

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

				sign_in( 'User', user )

				#
				#begin
				#	GoogleAnalyticsService.log_event 'User', 'Registration', client_id: params[:ga_client_id], event_label: user.email, dp: request.fullpath, __utma: cookies[:__utma], __utmz: cookies[:__utmz]
				#rescue => e
				#	logger.error e.message
				#	logger.error e.backtrace.join("\n")
				#end

				session.delete('warden.user.User.key')

				#session[:dest] = edit_person_path( id: user.slug )

			end


			def login_redirect( user )

				sign_in_and_redirect( user )

			end



		end
	end
end