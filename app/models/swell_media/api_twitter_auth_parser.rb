module SwellMedia

	class ApiTwitterAuthParser < ApiAuthParser

		def parse( params )


			@oauth_token = params[:token]
			@oauth_secret = params[:secret]
			@username = params[:username]
			@email = params[:email]

			begin

				consumer = OAuth::Consumer.new(ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"], { :site => "https://api.twitter.com", :scheme => :header })
				token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_secret }
				access_token = OAuth::AccessToken.from_hash(consumer, token_hash )

				@oauth_data = JSON.load(access_token.get('/1.1/account/verify_credentials.json?include_entities=false&skip_status=true&include_email=true').body)

				if @oauth_data['errors'].present?

					@oauth_data['errors'].each do |error|
						notice error['message']
					end

				end

			rescue Exception => e

				notice e

			end

			self
		end

		def first_name
			@oauth_data['name'].split(' ',2).first
		end

		def last_name
			@oauth_data['name'].split(' ',2).last
		end

		def location
			@oauth_data['location']
		end

		def email
			@email || @oauth_data['email']
		end

		def name
			@oauth_data['screen_name']
		end

		def avatar
			@oauth_data['profile_image_url']
		end

		def uid
			@oauth_data['id']
		end

		def oauth_token
			@oauth_token
		end

		def oauth_secret
			@oauth_secret
		end

		def provider
			'twitter'
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