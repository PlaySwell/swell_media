module SwellMedia
	class FacebookParser

		# maps a twitter @auth response to our user fields

		def initialize( auth )
			@auth = auth

			@og_user = FbGraph::User.me( oauth_token ).fetch

		end

		def first_name
			@auth['info']['first_name']
		end

		def last_name
			@auth['info']['last_name']
		end

		def location
			@auth['info']['location']
		end

		def email
			@auth['extra']['raw_info'].email
		end

		def name
			@auth['extra']['raw_info'].username || @auth['info']['first_name'].gsub( /[-\.]/, '_' ) + '_' + @auth['info']['last_name'].gsub( /[-\.]/, '_' )
		end

		def avatar
			"http://graph.facebook.com/#{@auth['uid']}/picture?type=large"
		end

		def uid
			@auth['uid']
		end

		def oauth_token
			@auth['credentials'].token
		end

		def oauth_secret
			@auth['credentials'].secret
		end

		def provider
			@auth['provider']
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
			@og_user.books.collect{ |i| i.name }
		end

		def games
			@og_user.games.collect{ |i| i.name }
		end

		def movies
			@og_user.movies.collect{ |i| i.name }
		end

		def music
			@og_user.music.collect{ |i| i.name }
		end

		def television
			@og_user.television.collect{ |i| i.name }
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


