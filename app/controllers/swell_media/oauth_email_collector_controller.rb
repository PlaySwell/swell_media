
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

		def after_sign_up_path_for( user )
			after_sign_in_path_for( user )
		end

	end
end