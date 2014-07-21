module SwellMedia
	class User < ActiveRecord::Base
		self.table_name = 'users'

		enum status: { 'active' => 0, 'revoked' => 1, 'archive' => 2, 'trash' => 3 }


		attr_accessor	:login

		### FILTERS		--------------------------------------------


		### VALIDATIONS	---------------------------------------------
		validates_uniqueness_of		:name, case_sensitive: false, allow_blank: true, if: :name_changed?
		validates_uniqueness_of		:email, case_sensitive: false, if: :email_changed?
		validates_format_of			:email, with: Devise.email_regexp, if: :email_changed?

		validates_confirmation_of	:password, if: :encrypted_password_changed?
		validates_length_of			:password, within: Devise.password_length, allow_blank: true, if: :encrypted_password_changed?

		### RELATIONSHIPS   	--------------------------------------
		has_many 	:user_roles, dependent: :destroy
		has_many	:roles, through: :user_roles

		

		### Plugins  	---------------------------------------------
		# Include default devise modules. Others available are:
		# :token_authenticatable, :confirmable,
		# :lockable, :timeoutable and :omniauthable
		devise :database_authenticatable, :omniauthable, :registerable, :recoverable, :rememberable, :trackable, authentication_keys: [ :login ]

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

	    def self.godmins
	    	joins( :user_roles ).joins( :roles ).where( roles: { name: 'godmin' } )
	    end


		### Instance Methods  	--------------------------------------

		def add_role( role )
			role_to_add = Role.where( name: role.to_s ).first_or_create
			self.roles << role_to_add
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
			self.first_name = name_array.shift
			self.last_name = name_array.join( ' ' )
		end


		def has_role?( role )
			return !!self.roles.find_by_name( role.to_s )
		end

		def possessive
	    	self.to_s + ( 's' == self.to_s[-1,1] ? "'" : "'s" )
		end

		def role
			self.roles.last.try( :name ) || 'None'
		end

		
		def to_s
			str = self.name || "#{self.first_name} #{self.last_name}"

			str = 'Guest' if str.blank?
			return str
		end

	end
end