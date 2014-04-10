class MediaOrigin < ActiveRecord::Base

	def self.not_youtube
		where( "slug <> 'youtube'" )
	end

end