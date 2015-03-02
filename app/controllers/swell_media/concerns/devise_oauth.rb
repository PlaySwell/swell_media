
require 'active_support/concern'

module SwellMedia
	module Concerns
		module DeviseOauth
			extend ActiveSupport::Concern

			include Devise::Controllers::Helpers
			include Devise::Controllers::SignInOut

			included do
				#scope :disabled, -> { where(disabled: true) }
			end

			####################################################
			# Class Methods

			module ClassMethods


			end


			####################################################
			# Instance Methods



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