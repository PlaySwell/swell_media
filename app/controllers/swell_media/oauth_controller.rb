module SwellMedia


	class OauthController < Devise::OmniauthCallbacksController

		include SwellMedia::Concerns::Oauth

		def facebook

			@response = SwellMedia::FacebookParser.new( request.env["omniauth.auth"] )

			response_auth( @response )

		end

		def twitter

			@response = SwellMedia::TwitterParser.new( request.env["omniauth.auth"] )

			response_auth( @response )

		end

		protected
		def after_omniauth_failure_path_for( resource )
			SwellMedia::Engine.routes.url_helpers.new_user_session_path
		end

	end

end