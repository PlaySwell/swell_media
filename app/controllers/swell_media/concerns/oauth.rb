
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

					record_user_event( event: 'login', user: credential.user, content: 'logged in.' )
					assign_anonymous_events( credential.user )
					
					login_redirect( credential.user )

				elsif current_user.present? && credential.nil?

					# login, new credential on existing user.

					credential = current_user.oauth_credentials.create!( response.credential_fields )

					current_user.update( avatar: response.avatar ) if current_user.avatar.blank?

					set_flash "#{credential.provider} account added."

					login_redirect( current_user )

				elsif current_user.present? && credential.present?

					if credential.user.present? && credential.user == current_user

						credential.update( response.credential_fields )

						login_redirect( current_user )

					else

						set_flash "#{credential.provider} account already exists."
						redirect_to '/'

					end

				else

					# new registration

					user = SwellMedia.registered_user_class.constantize.new_from_response( response )

					user.email = params[:email] if params[:email].present? && user.email.blank?

					if user.email.blank? || (SwellMedia.require_email_collector && params[:email_collected].nil?)

						@no_fb_closer = true
						@user = user

						redirect_to new_oauth_email_collector_path( response: response.encrypt )

					elsif user.save

						@new_registration = user
						registration_success user

						set_flash "Registration successful"

						record_user_event( event: 'registration', user: user, content: 'registered.' )
						assign_anonymous_events( user )

						user.on_registration

						register_redirect user

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


			def register_redirect( user )

				session[:dest] = after_sign_up_path_for( user )
				sign_in_and_redirect( user )

			end



		end
	end
end