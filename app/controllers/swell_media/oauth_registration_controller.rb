
module SwellMedia
	class OauthRegistrationController < ApplicationController

		include SwellMedia::Concerns::Oauth


		def create

			@response = EncryptedOauthParser.new( params[:response] )

			response_auth( @response )

		end

	end
end