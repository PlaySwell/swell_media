module SwellMedia
	class OauthCredential < ActiveRecord::Base

		belongs_to :user
	
	end
end