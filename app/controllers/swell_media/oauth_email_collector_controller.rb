
module SwellMedia
	class OauthEmailCollectorController < ApplicationController

		include SwellMedia::Concerns::Oauth


		def create

			@response = EncryptedOauthParser.new( params[:response] )

			response_auth( @response )

		end

		def new

			@response = EncryptedOauthParser.new( params[:response] )


			render layout: 'sessions'

		end

	end
end