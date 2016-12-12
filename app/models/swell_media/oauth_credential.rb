module SwellMedia
	class OauthCredential < ActiveRecord::Base
		self.table_name = 'oauth_credentials'

		belongs_to :user, class_name: SwellMedia.registered_user_class
	
	end
end