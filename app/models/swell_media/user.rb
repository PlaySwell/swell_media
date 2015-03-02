module SwellMedia
	class User < ActiveRecord::Base
		self.table_name = 'users'

		enum status: { 'pending' => 0, 'active' => 1, 'revoked' => 2, 'archive' => 3, 'trash' => 4 }
		enum role: { 'member' => 1, 'contributor' => 2, 'admin' => 3 }

		has_many	:assets, as: :parent_obj, dependent: :destroy
		has_many	:oauth_credentials, dependent: :destroy, class_name: SwellMedia::OauthCredential.name

		attr_accessor	:login

		### FILTERS		--------------------------------------------


		### VALIDATIONS	---------------------------------------------
		validates_uniqueness_of		:name, case_sensitive: false, allow_blank: true, if: :name_changed?
		validates_uniqueness_of		:email, case_sensitive: false, if: :email_changed?
		validates_format_of			:email, with: Devise.email_regexp, if: :email_changed?

		validates_confirmation_of	:password, if: :encrypted_password_changed?
		validates_length_of			:password, within: Devise.password_length, allow_blank: true, if: :encrypted_password_changed?

		### RELATIONSHIPS   	--------------------------------------
	
		include FriendlyId
		friendly_id :name, use: :slugged

		### Class Methods   	--------------------------------------
		# over-riding Deivse method to allow login via name or email
		def self.find_first_by_auth_conditions( warden_conditions )
			conditions = warden_conditions.dup
			if login = conditions.delete( :login )
				where( conditions ).where( ["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }] ).first
			else
				where( conditions ).first
			end
		end



		def self.new_from_response( response, args = {} )

			puts "new_from_response (a) - #{response.email}"

			user = User.find_by( email: response.email ) if response.email
			user ||= OauthCredential.where( provider: response.provider, uid: response.uid ).first.try(:user)

			puts "new_from_response (b) - #{user.try(:id)}, #{user.try(:full_name)}"

			if user.present?

				user.update( response.user_fields )

				credential = user.oauth_credentials.where( provider: response.provider, uid: response.uid ).first_or_initialize
				credential.update( response.credential_fields )

				return user

			end

			puts "new_from_response (c) - new user"
			user = (SwellMedia.registered_user_class || SwellMedia::User).new #( type: ( args[:type] || SwellMedia.registered_user_class ) )

			puts "new_from_response (d) - user fields"
			user.attributes = response.user_fields

			puts "new_from_response (e) - oauth creds"
			user.oauth_credentials.build( response.credential_fields )

			puts "new_from_response (f) - bits"

			user.books = response.books
			user.games = response.games
			user.movies = response.movies
			user.music = response.music
			user.television = response.television

			return user
		end


		### Instance Methods  	--------------------------------------

		def avatar_asset_file=( file )
			return false unless file.present?
			asset = ImageAsset.new(use: 'avatar', asset_type: 'image', status: 'active', parent_obj: self)
			asset.uploader = file
			asset.save
			self.avatar = asset.try(:url)
		end

		def avatar_asset_url
			nil
		end

		def avatar_asset_url=( url )
			return false unless url.present?
			asset = ImageAsset.initialize_from_url(url, use: 'avatar', asset_type: 'image', status: 'active', parent_obj: self)
			asset.save unless asset.nil?
			puts "avatar_asset_url= asset: #{asset}"
			self.avatar = asset.try(:url) || url
		end

		def avatar_tag( opts={} )
			tag = "<img src="
			tag += "'" + self.avatar_url( opts ) + "' "
			for key, value in opts do
				tag += key.to_s + "='" + value.to_s + "' "
			end
			tag += "/>"
			return tag.html_safe
			
		end


		def avatar_url( opts={} )
			# abstracts avatar path (uses gravatar if no avatar)
			# call as avatar_url( use_gravatar: true ) to over-ride avatar and force gravatar
			opts[:default] ||= 'identicon'

			if opts[:use_gravatar] || self.avatar.blank?
				return "http://gravatar.com/avatar/" + Digest::MD5.hexdigest( self.email ) + "?d=#{opts[:default]}"
			else
				return self.avatar
			end
		end


		def full_name
			if self.first_name.present? || self.last_name.present?
				"#{self.first_name} #{self.last_name}"
			else
				self.name
			end
		end

		def full_name=( name )
			name_array = name.split( / / )
			self.name = name
			self.first_name = name_array.shift
			self.last_name = name_array.join( ' ' )
		end


		def his_her
			if self.gender =~ /\Af/
				return 'her'
			elsif self.gender =~ /\Am/
				return 'his'
			else
				return 'their'
			end
		end

		def possessive( field=nil )
			if field.try( :to_s ) == 'first_name'
				self.first_name + ( 's' == self.first_name[-1,1] ? "'" : "'s" )
			else
	    		self.to_s + ( 's' == self.to_s[-1,1] ? "'" : "'s" )
	    	end
		end

		def registered_this_session?
			@registered_this_session
		end

		def on_registration
			@registered_this_session = true
			logger.info 'registered user'
			#begin
			#	RegistrationMailer.welcome( user ).deliver
			#rescue => e
			#	logger.error e.message
			#	logger.error e.backtrace.join("\n")
			#end
		end

		def on_login
			logger.info 'login user'

		end

		
		def to_s
			str = self.name || "#{self.first_name} #{self.last_name}"

			str = 'Guest' if str.blank?
			return str
		end

	end
end