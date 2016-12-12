module SwellMedia

	class ApiAuthParser

		def self.parse( params )

			"swell_media/api_#{params[:provider]}_auth_parser".camelize.constantize.new.parse( params )

		end

		def user

			user_id = SwellMedia::OauthCredential.where( provider: self.provider, uid: self.uid ).first.try(:user_id)

			@user = SwellMedia.registered_user_class.constantize.where( id: user_id ).first if user_id.present?

			unless @user.present?
				@new_user = true
				@user = SwellMedia.registered_user_class.constantize.new_from_response( self )
			end
			@user
		end

		def registration?
			@new_user || false
		end

		def errors
			@errors
		end

		def errors?
			@errors.present?
		end

		def encrypt

			crypt = ActiveSupport::MessageEncryptor.new(SwellMedia.encryption_secret)

			crypt.encrypt_and_sign({ credential_fields: credential_fields, user_fields: user_fields, interest_fields: interest_fields }.to_json)

		end

		protected
		def notice( args )

			message = args

			if args.is_a? Exception

				message = args.message

			end


			@errors ||= []
			@errors << message

		end

	end

end