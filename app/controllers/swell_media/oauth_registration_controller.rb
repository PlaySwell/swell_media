
module SwellMedia
	class OauthRegistrationController < ApplicationController

		include SwellMedia::Concerns::Oauth
		include SwellMedia::Concerns::DeviseOauth if SwellMedia.auth_method == :devise


		def create

			@response = EncryptedOauthParser.new( params[:response] )

			response_auth( @response )

		end

	end
end