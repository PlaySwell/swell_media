module SwellMedia
	class User < ActiveRecord::Base
		self.table_name = 'users'

		enum status: { 'unregistered' => -1, 'pending' => 0, 'active' => 1, 'revoked' => 2, 'archive' => 3, 'trash' => 4 }
		enum role: { 'member' => 1, 'ambassador' => 2, 'admin' => 3 }

		has_many	:assets, as: :parent_obj, dependent: :destroy
		has_many	:oauth_credentials, dependent: :destroy, class_name: SwellMedia::OauthCredential.name

		attr_accessor	:login

		### FILTERS		--------------------------------------------


		### VALIDATIONS	---------------------------------------------
		validates_uniqueness_of		:name, case_sensitive: false, allow_blank: true, if: :name_changed?, unless: :unregistered?
		validates_uniqueness_of		:email, case_sensitive: false, if: :email_changed?
		validates_format_of			:email, with: Devise.email_regexp, if: :email_changed?

		validates_confirmation_of	:password, if: :encrypted_password_changed?, unless: :unregistered?
		validates_length_of			:password, within: Devise.password_length, allow_blank: true, if: :encrypted_password_changed?, unless: :unregistered?

		### RELATIONSHIPS   	--------------------------------------
	
		include FriendlyId
		friendly_id :slugger, use: :slugged

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

			user = SwellMedia.registered_user_class.constantize.find_by( email: response.email ) if response.email
			user ||= OauthCredential.where( provider: response.provider, uid: response.uid ).first.try(:user)

			if user.present?

				user.update( response.user_fields )
				user.status = SwellMedia.default_user_status || 'pending' if user.unregistered?

				unless response.provider == 'email'
					credential = user.oauth_credentials.where( provider: response.provider, uid: response.uid ).first_or_initialize
					credential.update( response.credential_fields )
				end

				return user

			end
			user = SwellMedia.registered_user_class.constantize.new

			user.attributes = response.user_fields
			user.status = SwellMedia.default_user_status if ( user.email.blank? && SwellMedia.default_user_status.present? )

			user.oauth_credentials.build( response.credential_fields )

			# user.books = response.books
			# user.games = response.games
			# user.movies = response.movies
			# user.music = response.music
			# user.television = response.television

			return user
		end


		def self.not_unregistered
			where.not(status: SwellMedia.registered_user_class.constantize.statuses[:unregistered])
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
			protocol = ( opts.present? && opts.delete( :protocol ) ) || SwellMedia.default_protocol

			if opts[:use_gravatar] || self.avatar.blank?
				return "#{protocol}://gravatar.com/avatar/" + Digest::MD5.hexdigest( self.email ) + "?d=#{opts[:default]}"
			else
				return self.avatar.gsub(/^(https|http)\:/, "#{protocol}:")
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
			unless name.nil?
				name_array = name.split( / / )
				self.first_name = name_array.shift
				self.last_name = name_array.join( ' ' )
			end
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
				self.first_name.try(:strip) + ( 's' == self.first_name[-1,1].try(:strip) ? "'" : "'s" )
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


		def slugger
			self.name.present? ? self.name : self.full_name
		end

		
		def to_s( args={} ) 
			if args[:username]
				str = self.name.try(:strip)
				str = 'Guest' if str.blank?
				return str
			else
				str = "#{self.first_name} #{self.last_name}".strip
				str = self.name.try(:strip) if str.blank?
				str = 'Guest' if str.blank?
				return str
			end
		end

		def devise_scope
			SwellMedia.registered_user_class.constantize
		end

	end
end