module SwellMedia

	class ApiFacebookAuthParser < ApiAuthParser

		def parse( params )


			@oauth_token = params[:token]
			@username = params[:username]

			begin

				@og_user = FbGraph::User.me( @oauth_token ).fetch

			rescue Exception => e

				notice e

			end

			self
		end

		def first_name
			@og_user.first_name
		end

		def last_name
			@og_user.last_name
		end

		def location
			nil
		end

		def email
			@og_user.email
		end

		def name
			@username || @og_user.username || @og_user.name.downcase.gsub( /[^a-zA-Z]/, '_' )
		end

		def avatar
			"http://graph.facebook.com/#{uid}/picture?type=large"
		end

		def uid
			@og_user.identifier
		end

		def oauth_token
			@oauth_token
		end

		def oauth_secret
			#@auth['credentials'].secret
		end

		def provider
			'facebook'
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

	end

end