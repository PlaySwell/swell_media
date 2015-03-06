module SwellMedia
	class EncryptedOauthParser

		# maps a twitter @auth response to our user fields

		def initialize( auth )

			crypt = ActiveSupport::MessageEncryptor.new(SwellMedia.encryption_secret)

			@auth = JSON.parse crypt.decrypt_and_verify(auth)

		end

		def first_name
			@auth['user_fields']['first_name']
		end

		def last_name
			@auth['user_fields']['last_name']
		end

		def full_name
			"#{first_name} #{last_name}"
		end

		def location
			@auth['user_fields']['location']
		end

		def email
			@auth['user_fields']['email']
		end

		def name
			@auth['user_fields']['name']
		end

		def avatar
			@auth['user_fields']['avatar']
		end

		def uid
			@auth['credential_fields']['uid']
		end

		def oauth_token
			@auth['credential_fields']['oauth_token']
		end

		def oauth_secret
			@auth['credential_fields']['oauth_secret']
		end

		def provider
			@auth['credential_fields']['provider']
		end

		def credential_fields
			{
					name: name, provider: provider, uid: uid, token: oauth_token, secret: oauth_secret
			}
		end

		def user_fields
			{
					name: name, first_name: first_name, last_name: last_name, location: location, avatar: avatar, email: ( email.blank? ? nil : email )
			}
		end

		def books
			@auth['interest_fields']['books']
		end

		def games
			@auth['interest_fields']['games']
		end

		def movies
			@auth['interest_fields']['movies']
		end

		def music
			@auth['interest_fields']['music']
		end

		def television
			@auth['interest_fields']['television']
		end

		def interest_fields
			{
					books: books, games: games, movies: movies, music: music, television: television
			}
		end

		def encrypt

			crypt = ActiveSupport::MessageEncryptor.new(SwellMedia.encryption_secret)

			crypt.encrypt_and_sign({ credential_fields: credential_fields, user_fields: user_fields, interest_fields: interest_fields }.to_json)

		end

	end
end