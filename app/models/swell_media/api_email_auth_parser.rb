module SwellMedia

	class ApiEmailAuthParser < ApiAuthParser

		def parse( params )

			@login = params[:login]
			@email = params[:email]
			@username = params[:username]
			@password = params[:password]

			login_user = SwellMedia.registered_user_class.constantize.where( 'lower(email) = :login OR lower(name) = :login', login: @login.downcase ).first if @login.present?

			if @login.present? && ( login_user.nil? || not( login_user.valid_password?( @password ) ) )

				notice 'Invalid username and password.'

			elsif @login.present? && login_user.valid_password?( @password )

				@user 		= login_user
				@email 		= @user.email
				@username	= @user.name

			end

			self
		end

		def user

			unless @user.present?
				@new_user = true
				@user = SwellMedia.registered_user_class.constantize.new_from_response( self )
			end

			@user
		end

		def registration?
			@new_user || false
		end

		def first_name
			nil
		end

		def last_name
			nil
		end

		def location
			nil
		end

		def email
			@email
		end

		def name
			@username
		end

		def avatar
			nil
		end

		def uid
			@username
		end

		def oauth_token
			nil
		end

		def oauth_secret
			nil
		end

		def provider
			'email'
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

		def interest_fields
			{
					books: books, games: games, movies: movies, music: music, television: television
			}
		end

	end

end