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

	end

end