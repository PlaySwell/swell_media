module SwellMedia
	class OauthCredential < ActiveRecord::Base
		self.table_name = 'oauth_credentials'

		belongs_to :user
	
	end
end