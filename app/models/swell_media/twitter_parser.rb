module SwellMedia
	class TwitterParser

		# maps a twitter auth response to our user fields

		def initialize( auth )
			@auth = auth
		end

		def first_name
			split_name.first
		end

		def last_name
			split_name.last
		end

		def location
			@auth.info.location
		end

		def email
			nil
		end

		def name
			@auth.info.nickname
		end

		def avatar
			@auth.info.image
		end

		def uid
			@auth.uid
		end

		def oauth_token
			@auth.credentials.token
		end

		def oauth_secret
			@auth.credentials.secret
		end

		def provider
			@auth.provider
		end

		def credential_fields
			{
				name: name, provider: provider, uid: uid, token: oauth_token, secret: oauth_secret
			}
		end

		def user_fields
			{
				name: name, first_name: first_name, last_name: last_name, location: location, avatar: avatar
			}
		end

		def books
			[]
		end

		def games
			[]
		end

		def movies
			[]
		end

		def music
			[]
		end

		def television
			[]
		end


		private
			def split_name
				name = @auth.info.name
				if name.include?( " " )
					last_name  = name.split( " " ).last
					first_name = name.split( " " )[0...-1].join( " " )
				else
					first_name = name
					last_name  = nil
				end
				return [ first_name, last_name ]
			end
	end
end